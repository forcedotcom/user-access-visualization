user-access-visualization
=========================
This repository contains a Force.com IDE project related to the
Dreamforce '12 session entitled "Building Administrative Tools with
Permission Set API."  Specifically, this project provides a set of
VisualForce pages and Apex classes that demonstrate one possible way
of visualizing a user's complete set of access rights, at least those
access rights that are accessible via the SObject API.

installation
=========================
Probably the easiest way to install this visualization into your org
is to make use of the Force.com IDE.  Simply pull the repo down
locally and open the project within the IDE.  Once the project is open
within the IDE, you can either Deploy or Synchronize the code and
related resources with your organization.

For those without the Force.com IDE, the code is still relatively easy
to deploy.  The first step is to pull the repo locally and zip the src
directory and all it's contents (i.e., package.xml, classes/, etc.).
Then, open http://workbench.developerforce.com/ and login to the
desired organization with a user that has Modify All Data.  Select
*Deploy* from the *migration* menu.  Select the ZIP file you created
as the first step and deploy.

configuration and usage
=
The code contained within this repository creates a new VisualForce
page that is accessible at `/apex/UserAccessDetails`.  In order for
the page to operate properly, however, a user id must be provided via
a `uid` query parameter.  For example, to see the user access details
for a user with an id of `005E00000021x09`, the URL would be
`/apex/UserAccessDetails?uid=005E00000021x09`.  Failure to include an
appropriate uid query parameter will result in a fun error message.

Probably the best way make use of this is to create a custom link on
the user object and then add it to the user page layout.  This can be
done in a few quick steps.  First, select *Customize* | *Users* |
*Custom Links* from the setup page.  Click on *New* to create the
custom link and name the link whatever you'd like.  For the behavior,
I prefer *Display in existing window with sidebar*, but choose
whatever works best for you.  The "formula" for the custom link is
`/apex/UserAccessDetails?uid={!User.Id}`.  Once the custom link is
created, select *Customize* | *Users* | *Page Layouts* and edit the
desired page layout.  In the layout editor, drag the newly created
custom link onto the User layout as desired.

Keep in mind that you may need to grant access to the
`UserAccessDetails` Visualforce Page to the users who will be making
use of this.  If needed, this is done via either the user's profile or
(preferably!) via the appropriate permission set.