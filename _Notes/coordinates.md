#  Coordinates

Positive Z axis [in 'world' coordinates'?] is poiting through the screen towards me

zoom: change FOV (field of view) not POV

projection matrix defines volume in VIEW space aka eye space

model xform maps from 'local' coords to 'world' coords
view xform maps from 'world' to 'camera' coords
projection defines the volume in camera coords that gets put on the screen

final = projection * view * model * local
order of operation is right to left
