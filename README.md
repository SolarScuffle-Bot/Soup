# Soup
Soup is a minimalistic, lightweight ECS for luau.

The design goals are as follows:

    It needs to be efficient.
    It needs to be easy to use.
    It needs to be light weight.
    It needs to be applicable to any pre-existing codebase.
  
The result is Soup providing all the essential methods of an ECS without most potential overhead. Because it is so small it is encouraged to read the source for better familiarity.

It is written in a Data-Oriented Procedural style to further reduce overhead and improve data flow.

Because it does not attempt to do more than its purpose, it can be applied to pre-existing codebases without fear of massive rewrite.

Systems should be user defined structures and this is respected, allowing the user to write their systems wherever and however they please.

It is efficient and robust by design, applicable from game engines to your next tower defense game.

# Vocabulary

**Components**: *User-defined data.*

**Entities**: *Tables that reference unique components, associating them with eachother.*

**Constructors**: *Run during the creation of components and return them.*

**Destructors**: *Run during the deletion of components.*

**Collections**: *Contiguous arrays of same-type components.*

**Systems**: *User-implemented functions that transform Collections.*

# Documentation

    GetCollection(Name : Name_t) : Collection_t?
Returns the Collection of Name components, nil if nonexistant.

.

    CreateComponent(Entity : Entity_t, Name : Name_t, ... : any)
Creates a unique instance of Name component in Entity. Passes Entity as the first argument to the constructor. Private property automatically added to access the collection index for O(1) removal time. Entity property automatically added to guarentee access to Entity.

.

    DeleteComponent(Entity : Entity_t, Name : Name_t, ... : any)
Deletes the unique instance of Name component in Entity. Calls the Name destructor passing Entity with variable other arguments.

.

    ConstructComponent(Name : Name_t, Template : Template_t)
Sets the Name constructor to Template.Constructor or Template.constructor, destructor to Template.Destructor or Template.destructor, and collection to an empty array.

.

    DestructComponent(Name : Name_t)
Deletes all Name components and nils everything ConstructComponent set.

.

    CreateEntity() : Entity_t
Returns a new entity instance. Entities are tables of references to their components, useful for storing in external data structures.

.

    DeleteEntity(Entity : Entity_t)
Deletes all components in Entity using DeleteComponent. If no references are left to Entity the garbage colllector will clean it up.
