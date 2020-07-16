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
 * "texture slices"
 * <https://developer.apple.com/documentation/metal/mtlrenderpassdescriptor/rendering_to_multiple_texture_slices_in_a_draw_command>
4. Depth testing -- "depth texture" or "depth buffer"
 * <https://developer.apple.com/documentation/metal/calculating_primitive_visibility_using_depth_testing>
 * When I'm trying to make sure the node goes on top of the net, and the descent line goes on top of the node, I can use the order in which I submit commands to the command queue
 
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

        class FigureViewController {
            func installFigure(_ figure: Figure?) { ... }
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

> A: This guy <https://metalbyexample.com/vertex-descriptors> has a good answer: no. 
> He also talks about using a vertex descriptor. 


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


In Design19, each effect did its own rendering, maintained its own vertex/normal/color data, managed its own buffers, etc.
I don't yet see how to do that in Design20.

Note that the shell geometry has two effects specific to it: InnerShell and Meridians. Each one has its own set of vertex and color data and its own (set of) Metal buffer(s) and its own pipeline therefore. Because we want the figure code to be agnostic w/r/t geometry, we need to be able to add these two effects, with their vertex data and buffers, in a generic way. This means that **some** effects, at least, have their own pipelines.

What makes a pipeline?
  * vetex and fragment functions
  * references to buffers
  * other config parameters
  
commandBuffer.commit(...) is the thing that puts the commandbuffer (with its commands) on the queue. Time-ordering is enforced at the commandBuffer level. commit(...) happens after present(drawable)

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
It's what I'm calling 'Graphics20'

Cf. 'managed buffers' https://developer.apple.com/documentation/metal/buffers


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
rename Gaphics20 -> RenderContext


Pipelines and shaders
the render pipeline descriptor assigns buffer pointer + bufferIndex
the shader functions have attributes like <code>[[ buffer(0) ]]</code>

----

1 'present' using drawable per frame

so if I have multiple pipeline states / render encoders, I use them to create multiple commands and put them into the same queue. 
Then after they're all in the queue I do 'commit'.


