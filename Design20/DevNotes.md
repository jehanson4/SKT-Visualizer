# SKT Dev Notes

## Design20

### Metal support

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

Effects should then be given the geometric objects they need in order to render:

>       protocol Effect {
>           func render(..., projectionMatrix: float4x4, modelViewMatrix: float4x4, ...) { ... }
>       }


>       protocol SK2_Something {
>           var projectionMatrix: float4x4
>           var figureViewMatrix: float4x4
>           func setupGestures(...)
>           func teardownGestures(...)
>       }

Ok so far, but it's intimately connected to the geometry because of the worldViewMatrix. Maybe we should replace worldViewMatrix with a bounding box.
