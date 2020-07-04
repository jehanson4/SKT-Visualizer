# SKT Dev Notes

## Design20

### Metal support

Some articles:

1. <https://developer.apple.com/documentation/metal/basic_tasks_and_concepts/using_metal_to_draw_a_view_s_contents>
    * talks about setting device and clearColor on a MTLView
    * introduces the delegate
    * sez you GET the render pass descriptor from the view!
2. triple buffering:
  * <https://developer.apple.com/documentation/metal/synchronization/synchronizing_cpu_and_gpu_work>
3. Reusing vertex data
 * <https://developer.apple.com/documentation/metal/generating_multiple_output_vertex_streams_from_one_input_stream>
 * "vertex amplification"
 * "layered rendering"
 * "texture slides"
 * <https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor/rendering_to_multiple_texture_slices_in_a_draw_command>
4. Depth testing -- "depth texture" or "depth buffer"
 * <https://developer.apple.com/documentation/metal/calculating_primitive_visibility_using_depth_testing>
 * When I'm trying to make sufe the node goes on top of the net, and the descent line goes on top of the node, I can use the order in which I submit commands to the command queue
 
<https://developer.apple.com/videos/play/wwdc2019/611/>

<https://developer.apple.com/videos/play/wwdc2019/606/>

Modern Rendering with Metal
<https://developer.apple.com/videos/play/wwdc2019/601>
* Deferred rendering: 1st pass does geometry, then 2nd pass does lighting. Not something I need.


This page <https://developer.apple.com/documentation/metal/mtlrendercommandencoder> sez: render pass
1. create render command encoder
2. create render pipeline state incl setting shader func's
etc.

Metal best practices (archived, from 2017) sez:
* create 1 command queue at startup
* create 1 render pipeline state (early on) and reuse it
    * note that it includes the names of vertex and fragment functions

#### Figure and FigureViewController

I would prefer to keep the Metal dependencies as localized as possible. They need to be in at least two places:
1. the code that tells Metal what to draw, i.e., the Figures
2. the view controller that contains the Metal view, i.e., the FigureViewController

Let's try this:
* FigureViewController owns the app-wide Metal objects.
* Figure has method that passes those objects in, which FigureViewController calls when the figure is installed in the controller. Define it in a protocol to be adopted by FigureViewController.
* Figure also needs a method to permit it to free up memory from a figure that's being replaced

        protocol FigureUser {
            func installFigure(_ figure: Figure?)
        }

        protocol Figure {
            // ... stuff omitted ...
            func figureWillBeInstalled(...app wide metal stuff owned by Figure...)
            func figureWillBeUninstalled()
        }


Figures get installed in three contexts: startup; selection of new visualization; and selection of new figure within same visualization. 

For startup, let's always start with the same generic figure, e.g. a blank background. The alternative would be to start where we left off when the app was last shut down, *including* the segue to the UI controller for the visualization. That sounds fiddly to me so let's not do it. Which means, among other things, that the user preferences do *not* include a selected visualization. 

For selection changes, may as well continue to use ChangeMonitors. They need to be centrally located because the two selectors are driven from different UI view controllers. May as well put them into AppDelegate.

### Remembering state on app restart

Each visualization has "user preferences" that get written on application shutdown and read on subsequent startup. Because we're not choosing an initial visualization (see above), there's no user preference for selected visualization name.


### SK/2

#### Sharing code and state

There are multiple visuallzations, each with its own set of figures: SK/2 Equilibrium, Dynamics, Bifurcations. In the first two, the figures are the same shell and plane figures as always. Bifurcations figures are yet to be designed.

Let us share one system among all visualizations, so that user may switch among them without having to set system parameters in each.

>       class SK2_System { ... }

That means that we need to have single factory for all of SK/2. Use a static method because we only use it once. Put it in a class for future-proofing and familiarity.

>       class SK2_Factory {
>           static func makeVisualizations() -> [Visualization] { ... }
>       }

The various figures share more than just the system, but what and how much they share varies. E.g., sometimes only the vertex colors differ. We want them to share code and we need to split out the different dimensions along which they vary: colors, vertex and index arrays, default vertex positions, mod's due to Relief, etc.

*Q: Do we also want to share state among the figures? E.g., the vertex and index arrays?*

> A: No, at least for now. It introduces a lot of complexity for an uncertain benefit, and there will still be cases where we need to rebuild everything from scratch sometimes--e.g., change to N. 

*Q: for the vertex data, do we want to interleave it, a la Vertex class?*

> A: This guy <https://metalbyexample.com/vertex-descriptors> has a good answer: no. And use a vertex descriptor. 


#### Geometry 

All the SK/2 figures designed to date have effects, some switchable and some not. Some of the effects are at least conceptually independent of whether it's a plane or a shell figure. I'd like to abstract the 'geometry' that sets node positions and normals in such a way that I only need one class for, say a Net or Surface or Nodes effect, which may be used in either shell or plane figures. (Note however that some effects do depend on which kind of figure it is: Meridians, for example.)

Let's abstract the geometrical stuff this way:

>       protocol SK2_Geometry {
>           func buildVertexCoordinates(...) -> [SIMD3<Float>]()
>           func buildVertexNormals(...) -> [SIMD3<Float>]()
>       }
>
>       class SK2_PlaneGeometry : SK2_Geometry { ... }
>
>       class SK2_ShellGeometry : SK2_Geometry { ... }

To render the nodes, we need projection & modelView matrices and we need to manage a POV that changes in response to UI gestures. The values of matrix elements and the vertex coordinates are tightly coupled--basically, via the vertices' bounding box. The actual bounding box might depend on the system parameters, but we can define a 'nominal' bbox that doesn't. If I ever want to have two subfigures (e.g., 2 planes side by side showing different quantities, or a plane and a shell, or etc.) then I would want to embed two sets of vertices into the same 3d space. I would want my pan gestures to rotate each subfigure rather than rotating the figure as a whole. This means each subfigure gets its own POV support and modelView matrix.

*Q: What about projection matrix?*

> A: Keep it with the modelView matrix for now. Two projection matrices for one figure doesn't make sense to me. But if I want two perspective projections, wouldn't I have to? Maybe I should use two different MTLViews?

In Design19, the projectionMatrix in a PlaneFigure depends on flyover vs satellite mode and pov.z, whereas in ShellFigure it never changes. The POV is also common to all effects, but it changes frequently. Its variables depend on the geometry type. In Design19, it's the thing the gestures operate on, and the figure's modelViewMatrix is created from it. In the HelloMetal demo he's putting the projectionMatrix and the rendered object's modelViewMatrix into the uniforms buffer and having the shader's vertex function do the matrix multiplication.

I see three options for deailing with the matrix and POV stuff:
1. put in the Figure class, as in Design19. This is inflexible. I'd like a Figure to be a thin container so I can reuse more code.
2. put it in the geometry class. This is simplest and enforces consistency with node placement. I think putting gesture support in it is wrong, but until I've got an example that needs to do something else, I don't know what is right.
3. put in in its own class, and define a protocol for it. This has better separation of concerns, but I can't think of a good name for it--which means it hasn't gelled.
Despite its disadvantages, let's go with #2:

>       protocol SK2_Geometry {
>           var projectionMatrix: float 4x4 { get, set }
>           var modelViewMatrix: float4x4 { get, set }
>
>           func resetPOV()
>           func connectGestures(...)
>           func disconnectGestures(...)
>       }
>
>       class SK2_PlaneGeometry : SK2_Geometry {
>           var center: SIMD3<Float> = SIMD3<Float>(0.0, 0.0, 0.0)
>           var gridSize: Float = 1.0
>       }
>
>       class SK2_ShellGeometry : SK2_Geometry {
>           var center: SIMD3<Float> = SIMD3<Float>(0.0, 0.0, 0.0)
>           var radius: Float = 1.0
>       }

*Q: Can we generalize the geometry beyond SK2? Should we?*

> A: definitely can, but it's premature because we don't have any examples to tell us how. We'd fall into the trap of **False Generality**. Let's wait until we have a non-SK2 system for which we need a plane or shell figure, then retrofit it in.

#### Effects

*Q: in Design19, you turn the rellief on and off via an Effect. How will it work in Design20?*

> A: Same way, though the internal details may be different. TBD.

In Design19, each effect did its own rendering, maintained its own vertex/normal/color data, managed its own buffers, etc.
I think that's not the right way to go. Effects should basically be named switches that modify a code path that follows the
HelloMetal demo. E.g., there's a single pipeline descriptor.

I would also like to have them own their own data and generate their own render commands. But I don't want redundant copying
of node coordinates. I could make the effects' data objects settable:
>           protocol DS_NodeEffecct {
>               var nodeCoords: [SIMD3<Float>] { get set }
>           }

An effect that has data needs to manage the associated MTLBuffer, but the buffers and indices need to be known to the figure
in order to create the pipline state. I have a fixed finite set of effect-data-arrays. So I should ebed the buffer indices as named constants.
>           class SK2_Figure_20 {
>               static let NODE_COORDINATES_BUFFER_INDEX = 0
>               ...
>           }

Note that I'd have to know its buffer too, and keep track of whether the buffer's content is stale

If I'm going to use triple buffering then I'll want a BufferProvider class as well. To avoid unnecessary copying I need to be cagey about whether to copy the data or not . . . maybe version numbers? I think I'll want something that does all the buffer management stuff in one place. That way I can start with simple code (that does unnecessary copying) and improve it.

Assume vertexDescriptor and pipelineDescriptor and pipelineState are all set up when figure is installed. That sets all the buffer indices and the shader commands.

Possible to create & configure more than one pipeline

commandBuffer.commit(...) is the thing that puts the commandbuffer (with its commands) on the queue. Time-ordering is enforced at the commandBuffer level. commin(...) happens after present(drawable)

I start a render pass. I create a renderPassDescriptor, if that's common across all effects (I assume it is). Then I have each effect that draws something add an entry to the command queue--i.e., it creates a commandBuffer and renderEncoder, sets them up, and adds the command to the queue.

There's some common stuff that is done to all renderEncoders. Who does that stuff?

How does the code change when I'm putting multiple things onto the command queue?  . . . the answer was in one of the Apple examples. . . .

How do I get UI-driven change in Relief enablement to cause invalidation of node coordinates?

### SK2_Figure_20

All these different things are mixed up together:
1. effects switch on and off
2. diff physical quantities depend on different system params
3. different effects use different vertex/index/normal/color data & associated buffers
4. would v much like to be able to drop a new effect into the figure w/o having to rewrite everything
5. POV changes and data changes occur separately

maybe my lazy-calculation stuff is a bad idea? Let's take it as a design challenge.

POV changes work like this:
1. geometry maintains the matrices.
2. marks them stale when POV changes
3. at beginning of render pass, updates them iff stale
4. Iff they change, the new values get copied into the uniforms 

X changes work like this:
1. something maintains the X data
2. it marks them stale when dependencies change
3. at beginning of render pass, updates them iff stale
4. Iff they change, the new values get copied into the correct buffer(s)

>       BufferManager {
>       }
>       
>       Figure {
>           var bufferManagers: [String: BufferManager]
>       }

#### RenderingContext

Some blogger uses a 'rendering context' somewhere. That's the right abstration.

Context needs to be an aggregation, because of Meridians. Thre needs to be a way for the shell geometry
to add meridians to the list of effects, and have meridians add a specialized part/aspect/facet to the context.

Ability to dynamically add facets means that the context needs to dynamically calculate the index for the facet's buffer.

I suppose each facet will be a specialized subclass of the 'facet' protocol.

There also needs to be a way to update the list of which parts of the context are needed by the enabled effects.
We can clear the list at the beginning of the update step then active effects turn on the things they need.

Note that the context's facets are very much like the figure's effects.

>       procotol SK2_RenderingContextFacet_20 {
>           var name: String { get }
>           var enabled: Bool { get set }
>
>           func install(in context: SK2_RenderingContext_20)
>           func update(...)
>       }
>
>       protocol SK2_Effect_20 {
>           func installFacets(in context: SK2_RenderingContext_20)
>           func enableFacets(in context: SK2_RenderingContext_20)
>           func render(context: SK2_RenderingContext_20, ...)
>       }
>

Cf. 'managed buffers' https://developer.apple.com/documentation/metal/buffers

*Q: how to force deallocation?*

>       struct BufferData {
>           buffer: MTLBuffer?
>           bufferIndex: Int
>       }
>
>       class SK2_RenderingContext_20 {
>           
>           var facets: [String: SK2_RenderingContextFacet_20]
>
>           /// an effect will call this when creating a new facet
>           func createBuffer() -> BufferData { ... }
>       
>           
>           func update() { // have all enabled facets update themselves }
>           
>       }
>
>       class SK2_Figure_20 {
>
>           func update(...) {
>               context.reset()
>               for effect in effects {
>                   if (effect.enabled) {
>                       effect.updateActiveAspects(context)
>                   }
>               }
>               context.update()
>           }
>
>           func render(...) {
>               for effect in effects {
>                   effect.render(context, ...)
>               }
>           }
>       }

Repackage with convenience methods as desired.


*Q: Can we delegate the creation of the pipeline state and the facets to another object?*
> A: Perhaps. The set of facets is determined by the set of effects and the geometry.
>   * the delegate must contain the geometry
>   * the delegate must create the effects as well as the facets

Given all that, it's more of a configurer/builder than a delegate.  It doesn't need to be an attribute in the renderEngine class. SK_Figure creates a render engine, so it can configure it too. The figure can create all the facets and the effects and the pipeline state.

But remember, there are effects and/or facets contributed by the geometry. They have buffers too, and the vertex descriptor needs to be told about them. The Figure can create the pipeline state and pass it to the render engine. But it will need to do it via API calls on the facets and the geometry. The geometry should have 'installFacets' member and the facets its installs should participate in creating the vertex descriptor.

The figure sets the vertex and fragment functions and some other things on the pipeline state, then has the facets set up the vertex descriptor.
It can create a list of facets, including any that it gets from the geometry.

The way I've got it now is this:
1. figure creates render engine
2. figure installs the effects in the engine. It gets some from the geometry.
4. When each effect is installed, it immediately creates any as-yet-uncreated facets it needs and installs then in the engine. This means that the only place where all extant facets are available is the engine's facet registry.
5. each facet allocates/manages its buffers. It gets its buffer indices from the engine **at facet installation time**.
6. figure creates the context's pipeline state. It sets the vertex and fragment function. It assembles the vertex descriptor with help from the facets installed in the engine. It passes the pipeline state object to the engine.

That's so damn complicated!

The last item is icky. It's got too much back-and-forth between the engine and the figure. I would be much happier if the engine created the pipeline state, using the facets in its registry plus any other info it needs.

We can do that by passing vertex and fragment function names to the render engine.
Call it a SimpleRenderEngine? Single pipe etc.

*Q: if we go around dynamically adding things to the vertex descriptor, how will our shader functions work?*

> A: **They wont.** We can deal with the unforms by having the figure create the uniforms buffer right before installing the facets. That way it'll always have buffer index 0. **That does not help with the vertex positions** Different effects will use different metal buffers to store vertex position data. (Meridians being the defining example).

### Back to the drawing board.

**Here's the set of SK2 effects:**

  * Points
    * uses node coords + buffer, node colors + buffer, basic shaders, point size
    * vertices are node positions
    * uniforms: { modelview matrix, projection matrix, point size, colors enabled, white color }
    * shader func's: use point size; depending on whether colors enabled, use vertex color or white color
  * Surface
    * differs from Points by using an index array for drawing triangles; and does not use point siz
    * needs a metal buffer for index array
    * Does it need its own shader func's? If so then it needs its own pipeline
    * it should NOT recalculate node coords or colors, tho.
  * Net
    * uses node coords + buffer, segment index array + buffer, monochrome shaders (white color)
  * Descent Lines
    * uses its own segment coords (derived from node coords) + buffer, monochrome (white color)
  * Meridians
    * uses its own segment coords + buffer, maybe index array, monochrome (blue color)
    * has its own pipeline
  * Busy spinner
    * shows its own texture . . . therefore its own shader functions 
    * has its own pipeline
  * Relief switch
    * sets a parameter that modifies output of other effects
    * no pipeline
  * Color switch
    * sets a parameter that modifies output of other effects
    * no pipeline
  * plane-figure POV mode switch (include this to make sure design is generalizable)
    * sets a parameter that modifies output of other effects
    * no pipeline

----

Could set up multiple pipelines and use simple shader func's that have their buffer indices represented as literals in the source code
That won't let Meridians be handled generically -- its index is set at the Figure level, not geometry level. Not too happy about that!

Q: **sharing of node coordinates** -- let's do it. But how?


Any given figure will have effects and it will have been initialized with color provider (which does not change ever) and relief provider (ditto)
SO why not also give it a coordinate provider, aka geometry.
  * geometry knows *how* to calculate 'em
  * which component knows *when or whether* to calculate 'em?

Depending on the nature of the relief and the sequencer, it may or may not have to recalculate....ever But a sequencer that doesn't change the data is a boring edge case so don't design to it.

a typical effect needs its own idiosyncratic data in one way or another.

Forget the facets.

SOME effects have pipelines, some do not.
pipelines are owned by effects. no sharing of pipeline state between effects
No sharing of buffers between effects.
Sharing of node coords is done under management of the figure. The figure holds an array of node coords, which is only updated on demand.

No 'rendering engine' -- embed it in the Figure class
use Graphics20 in place of RenderContext20
rename Gaphics20 in fact



