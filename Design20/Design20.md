# Design20

## Goals

1. simplfy and clarify
2. port to Metal

## Components

### ApplicationDelegate

Has a Registry of Visualizations and app-wide graphics objects

### Visualization:

Primary subdivision of the app. Examples: Demos; SK2/E 

Each Visualization has a name, at most one PhysicalSystem, one or more Figures, and any number of Sequencers.

User preferences:
1. Name of most-recently-selected Figure
2. Name of most-recently-selected Sequencer
3. User preferences for the PhysicalSystem, all Figures, and all Sequencers


### PhysicalSystem

The thing being visualized. It may have any number of PhysicalParameters.

Different PhysicalSystems do not share data.

User preferences:
1. Current values and user preferences of all PhysicalParameters

### PhysicalParameter

A self-describing parameter of a PhysicalSystem. Has a name and bounds and change-size

User preferences:
change-size

### Figure

Renders content to the Metal View in the FigureViewController.

A Figure has a name and a group.

A Figure is lightweight until installed.

A Figure has setup and teardown methods.

A Figure sets up its own support for gestures

A Figures may have Effects. Figures with Effects maintain a Registry of available effects and a list of currently enabled ones.
It has a default set of enabled ones for first-time setup

User preferences:
current set of effects


### Effect

Aspect or part of a figure that may be added/removed at runtime
Effects do not have configurable parameters.
No user preferences

### FigureViewController

Holds the Metal view that shows the currently-installed Figure.

Installs a default Figure as soon as it is loaded

Replacing the Figure:
1. store current Figure in temp variable for later teardown
2. prepare new Figure for rendering
3. safely set current Figure to new Figure
4. tear down old Figure

### Sequencer

Animates a figure, e.g. by changing the PhysicalSystem's PhysicalParameters

## Control flow

### Application startup

1. ApplicationDelegate creates and registers all Visualizations.
2. ApplicationDelegate reads User preferences and applies them to all Visualizations
3. ApplicationDelegate creates the app-wide common graphics objects: device, etc. and installs them in the FigureViewController

### Application shutdown

1. User preferences are collected for all Visualizations and then stored

### Change of Visualization

1. Old Figure is uninstalled from the FigureViewController
2. If the new Visualization has non-nil most-recently-selected Figure, it is installed into the FigureViewController
3. If not, a default Figure is installed
4. Update the UI controls

### Change of Figure with same Visualization

1. Old Figure is uninstalled from the FigureViewController
2. New Figure is installed into the FigureViewController
3. Update the UI controls

### Change of Sequencer within same Visualization

* 1. Update the UI controls

## General Rules

### Protocols and base classes

* Keep "abstract" base classes to a minimum
* Use a protocol only when there's going to be multiple concrete classes that want to adopt it.

### Registries and Selectors

* Always use a Registry in generic way. There should be no assumptions about what its entry keys are.
* Entry "names" are deprecated. Do not use them.
* ChangeMonitors may be overcomplex. Let's try to avoid them.
