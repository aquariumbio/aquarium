# Locations #

## Bench Locations ##

If an item is stored on a shelf, drawer, etc, it will have a location of the form B1.510, which in this case means Bay 1, location 510. The first digit of 510 is the height from the floor, with the 300s being bench level. Thus, 500 is two shelves up from the bench. The second two digits, in this case 10, show where on the shelf going from left to right across the bay. So B1.510 means bay 1, second shelf above the bench, near the left most side of the bay. There are stickers that should guide you to the exact spot.

## Sample Locations ##

Samples are stored using various prefixes, which are handled by the Location Wizard, a piece of software that determines the next available location for a newly minted sample. Any ObjectType can be associated with a prefix which then determines the behavior of the Location Wizard. The association of ObjectType to prefix can be made on either the 'New ObjectType' or 'Edit ObjectType' page.

All sample locations have the form PR.x.y.z where PR is one of the prefixes described below, and x, y and z are location identifiers that have specific meanings according to the prefix. As an example, if a sample has the location M20.4.5.87, then it is stored in a -20C freezer in hotel 4, box 5, slot 87.

The currently recognized prefixes and their behaviors are as follows.

* M20.x.y.z The -20C sample space is separated into aluminum hotels, numbered x=0,1,2, ... The number of hotels is essentially unlimited (we'll buy more as we need them). Which hotels are in which freezer should be shown on the door of the freezer. Each hotel holds y=0..15 boxes, and each box has z=0..99 slots numbered from the upper left, then accross the top row ro slot 9, then to the left of the next row for 10-19, etc. When a new sample is made in an ObjectType with prefix M20, the location wizard determines the new address by finding the next slot in the box with samples of the same project (a.k.a. category), or a new box if such box is full. Thus, only samples with for the same project will be found in a given box.

* M80.x.y.z The -80C sample space is organized the same way as the -20C sample space.

* DFS.x.y.z The deli fridge sample space is organized the same way as the -20C sample space.

* SFw.0.y.z There are a number of small -20C freezers in the lab number SF1, SF2, ... These each contain boxes, numbered y=0,1,2,... The location wizard puts new samples stored in ObjectTypes with prefix SF1, SF2, etc into boxes according to project by assigning the next available slot, which might be in a new box if the current project boxes are full.