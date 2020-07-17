#  Design 21: Dev Notes

Major components:
  * **DSModel**: the thing being visualized. E.g., an S-K spin glass. "DS" stands for "Dynamical System"
  * **DSParam**: an adjustable parameter of a DSModel. E.g., temperature or number of spins.
  * **Figure**: the thing that gets displayed on the screen.
  * **Sequencer**: generates a sequence of changes to an animated Figure. E.g., changes the temperature in a stepwise fashion
  * **Visualization**: a group of Figures and Sequencers that show a given DSModel in various ways



