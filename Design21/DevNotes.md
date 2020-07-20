#  Design 21: Dev Notes

Major components:

  * **DSModel**: the thing being visualized. E.g., an S-K spin glass. "DS" stands for "Dynamical System"
  * **DSParameter**: an adjustable parameter of a DSModel. E.g., temperature or number of spins.
  * **DSObservable**: provides visualization data to a Figure. E.g., node colors or evlevations
  * **Figure**: the thing that gets displayed on the screen.
  * **Sequencer**: generates a sequence of changes to an animated Figure. E.g., changes the temperature in a stepwise fashion
  * **Visualization**: a group of Figures and Sequencers that show a given DSModel in various ways



## Event flow

We use PropertyChangeEvents throughout.

On receiving a PropertyChangeEvent, the recipient will set internal flag(s) signifying this or that of its properties needs updating.

Before each render pass, all updates are performed.

### UI interactions

Change in any model param (or more than one)

    1 change in model paramcauses model to send event to observable
    2 observable checks for relevance
    3 observable marks calibration as stale
    4 observable sends event to the figure w/ property = "values"
    5 figure marks these things as stale:
        1 node count 
        2 node colors
        3 node positions
        
### Effects

#### MISC

  * setup(context: RenderContext) -- the arg is so that we can implement BusySpinner once for all figures
