**nextmeal-ios**
===================

Next Meal iOS client.

Includes:
- Universal iOS app
- Today Widget extension
- Watch App extension
- iMessage extension using base project from [github.com/Fluffcorn](https://github.com/Fluffcorn/ios-sticker-packs-app).

Customizing behavior
-------
The behavior of the application may be customized through the `Constants.h` file. 

Explanation of iOS app subclasses
-------
In the iOS app for the `UITableViewController` subclass, the ***Display** classes include the code for only displaying the UITableView, ex: `UITableViewDataSource` methods. 
The subclasses which are named bare without any suffixes are subclasses of the ***Display** classes. They contain methods that actually initiate and handle the refreshing and reloading the `UITableView`. 
The header files suffixed wth ***Subclass** are contain interfaces for the ***Display** classes. These interfaces expose properties of the ***Display** classes that are meant to be protected (accessible only to the parent and subclasses). The ***Subclass** files are imported in the ***Display** classes and any subclasses of the ***Display** classes that require use of the parent class properties.


Next Meal source code is distributed under MIT License. Attribution to Anson Liu is required.
All sticker assets to used under fair use and are copyright to their original creators.  