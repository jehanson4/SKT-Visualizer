# SKT Dev Notes

## Design21

### Metal support

#### Figure and FigureViewController

I would prefer to keep the Metal dependencies as localized as possible. They need to be in at least two places:
1. the code that tells Metal what to draw, i.e., the Figures
2. the view controller that contains the Metal view, i.e., the FigureViewController

Let's try this:
* FigureViewController owns the app-wide Metal objects.
* Figure has method that passes those objects in, which FigureViewController calls when the figure is installed in the controller. Define it in a protocol to be adopted by FigureViewController.
* Figure also needs a method to permit it to free up memory from a figure that's being replaced

        protocol FigureUser21 {
            func installFigure(_ figure: Figure21?)
        }

        protocol Figure21 {
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

A: No, at least for now. It introduces a lot of complexity for an uncertain benefit, and there will still be cases where we need to rebuild everything from scratch sometimes--e.g., change to N. 

*Q: for the vertex data, do we want to interleave it, a la Vertex class?*

A: This guy <https://metalbyexample.com/vertex-descriptors> has a good answer: no. And use a vertex descriptor. 
