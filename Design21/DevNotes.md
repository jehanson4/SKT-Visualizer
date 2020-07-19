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
