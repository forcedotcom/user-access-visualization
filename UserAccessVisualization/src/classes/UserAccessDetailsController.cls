/**
 * Copyright (c) 2012, Salesforce.com, Inc.  All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 * 
 *   * Neither the name of Salesforce.com nor the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
public class UserAccessDetailsController {
    // Define some constants so we can avoid magic strings.  At the very least, by using
    // constants, we avoid mismatches due to typos.
    private static final String PERMISSIONS = 'permissions';
    private static final String CREATE = 'permissionscreate';
    private static final String READ = 'permissionsread';
    private static final String EDIT = 'permissionsedit';
    private static final String DELET = 'permissionsdelete';
    private static final String VAR = 'permissionsviewallrecords';
    private static final String MAR = 'permissionsmodifyallrecords';

    //
    // Be careful about the amount of viewstate to carry.  Too much viewstate has a
    // negative impact on performance.  Plus, it's just a bad idea to carry around stuff
    // that you don't need from request to request.
    //

    // The user is pretty central to this demonstration page and is needed for almost any
    // and every request.  We don't actually hold on to a lot of user data, so this should
    // be OK to carry around the view state.
    private Id userId;
    public String userFullName { get; private set; }

    // Likewise, the list of permsets for which we're displaying information is pretty
    // important for every request, so we should hold on to that in viewstate.
    public List<NameLabel> permsetInfo { get; private set; }
    
    // A note about the various MapHolder variables.  These are Maps for permission set id
    // to access settings construct.  Each of these maps will have one entry with a null
    // key which represents the users total access.
    
    // User perm info is only used for the initial request, so don't hold on to it.  The
    // comments on the following lines identify the patterns used for variables declared
    // in subsequent blocks.
    private transient List<NameLabel> xUserPermLabels;  // API Names and Labels, and IDs
    private transient MapHolder xUserPermStatus;        // Which perms are enabled for this user
    private transient Map<Id,PermissionSet> xUserPerms; // Map from permset Id to PermissionSet Object, 
                                                        // which has the userperm settings 

    // Likewise, object perm info is only used for the initial request, so don't hold on to it
    private transient List<NameLabel> xObjectLabels;
    private transient MapHolder xObjectStatus;
    // Map from permset id -> object name -> ObjectPermissions object.
    private transient Map<Id,Map<String,ObjectPermissions>> xObjectPerms;

    // FLS info used for rendering is only used a single time per request and not needed
    // from request to request, so we don't need to hold on to it.    
    private transient List<NameLabel> xFieldLabels;
    private transient MapHolder xFieldStatus;
    // Map from permset id -> field name -> FieldPermissions object.  This is the set of
    // FLS data relevant for the object defined by flsObjectType (see below)
    private transient Map<Id,Map<String,FieldPermissions>> xFls;
    
    // flsObjectType contains the name of the object for which we display FLS information.
    // the VisualForce page uses this as a way to handle actionFunctions, allowing for
    // click-based interaction via javascript
    public String flsObjectType { 
        get {
            if (null != userId && null == flsObjectType) {
            	// Default flsObjectType to the first "visible" object.
                for (NameLabel nl : getObjectLabels()) {
                    if (getObjectPermStatus().it.get(nl.apiName)) {
                        flsObjectType = nl.apiName;
                        break;
                    }
                }
            }
            return flsObjectType;
        }
        set {
            if (value != flsObjectType) {
            	// When setting flsObjectType, ensure that all the
            	// FLS stuff is cleared out so that we are forced to
            	// recalculate
                xFls = null;
                xFieldLabels = null;
                xFieldStatus = null;
                flsObjectType = value;
            }
        }
    }
    
    // ApexClass info is only used during the initial request.  Don't need to hold on to it.
    private transient List<NameLabel> xClassNames;
    private transient Map<Id,Map<String,Boolean>> xApexClasses;

    // Likewise, we don't need to hold onto VisualForce page information.
    private transient List<NameLabel> xPageNames;
    private transient Map<Id,Map<String,Boolean>> xPages;
    
    public UserAccessDetailsController() {
    	// Expect a uid Query Parameter
        if (ApexPages.currentPage().getParameters().containsKey('uid')) {
            lookup(ApexPages.currentPage().getParameters().get('uid'));
        }
    }
    
    /**
     * Looks up the target user and loads all their permission set info (name / label)
     */
    private void lookup(Id uid) {
        try {
            User userData = [SELECT Id, Name,
                                    (SELECT PermissionSet.Id, PermissionSet.Name, PermissionSet.Label,
                                            PermissionSet.IsOwnedByProfile, PermissionSet.Profile.Name
                                       FROM PermissionSetAssignments) 
                               FROM User
                              WHERE Id = :uid];
            userId = userData.Id;
            userFullName = userData.Name;
            
            NameLabel totalAccess = new NameLabel('1TOTAL_ACCESS', 'TOTAL ACCESS');
            NameLabel profilePermsetInfo;
            List<NameLabel> nls = new List<NameLabel>();
            for (PermissionSetAssignment psa : userData.PermissionSetAssignments) {
                if (psa.PermissionSet.isOwnedByProfile) {
                    profilePermsetInfo = new NameLabel(
                        psa.PermissionSet.Id, psa.PermissionSet.Name, psa.PermissionSet.Profile.Name
                    );
                } else {
                    nls.add(new NameLabel(
                        psa.PermissionSet.Id, psa.PermissionSet.Name, psa.PermissionSet.Label
                    ));
                }
            }

            permsetInfo = new List<NameLabel>();
            permsetInfo.add(totalAccess);
            permsetInfo.add(profilePermsetInfo);
            if (!nls.isEmpty()) {
                nls.sort();
                permsetInfo.addAll(nls);
            }
        } catch (DMLException ex) {
            // Don't care?
        }
    }
    
    /**
     * Use Apex describe information to determine the set of User Permissions available within
     * this organization.
     */
    public List<NameLabel> getUserPermLabels() {
        if (null == xUserPermLabels) {
            List<NameLabel> result = new List<NameLabel>();
            Map<String, Schema.SObjectField> fMap = Schema.SObjectType.PermissionSet.fields.getMap();
            for (String fName : fMap.keySet()) {
                if (fName.startsWith(PERMISSIONS)) {
                    String label = fMap.get(fName).getDescribe().getLabel();
                    result.add(new NameLabel(fName, label));
                }
            }
            result.sort();
            xUserPermLabels = result;
        }
        return xUserPermLabels;
    }
    
    /**
     * Load the permission set information.  Yes, we could slightly optimize this by loading
     * this at the same time we load the permission set label information, but separating
     * the two keeps the code cleaner.
     */
    public Map<Id,PermissionSet> getUserPerms() {
        if (null == xUserPerms) {
            Map<Id,PermissionSet> result = new Map<Id,PermissionSet>();
            // Compute total access along the way.
            PermissionSet totalAccess = new PermissionSet();
            result.put(null, totalAccess);
            for (SObject sobj : queryUserPerms(extractPsIds(permsetInfo))) {
                PermissionSet ps = (PermissionSet) sobj;
                result.put(ps.Id, ps);
                for (NameLabel nl : getUserPermLabels()) {
                	// Total access computation
                    totalAccess.put(nl.apiName, 
                       getWithDefault(totalAccess, nl.apiName, false) 
                       || getWithDefault(sobj, nl.apiName, false));
                }
            }
            xUserPerms = result;
        }
        return xUserPerms;
    }
    
    /**
     * Helper function to encapsulate default handling of Boolean fields.  This is
     * assuredly overkill, but oh well...
     */
    private Boolean getWithDefault(SObject sobj, String fld, Boolean dflt) {
        try {
            if (null == sobj.get(fld)) return false;
            return (Boolean) sobj.get(fld);
        } catch (Exception ex) {
            return dflt;
        }
    }
    
    /**
     * Basically provides an alternate representation of total access to make our
     * grid display consistent between access settings.
     */
    public MapHolder getUserPermStatus() {
        if (null == xUserPermStatus) {
            PermissionSet totalAccess = getUserPerms().get(null);
            Map<String,Boolean> msb = new Map<String,Boolean>();
            for (NameLabel nl : getUserPermLabels()) {
                msb.put(nl.apiName, (Boolean) totalAccess.get(nl.apiName));
            }
            xUserPermStatus = new MapHolder(msb);
        }
        return xUserPermStatus;
    }
    
    /**
     * Transforms a list of NameLabel objects into just a List of Id objects
     */
    private List<Id> extractPsIds(List<NameLabel> psInfo) {
        List<Id> result = new List<Id>();
        for (NameLabel nl : psInfo) {
            if (null != nl.Id) result.add(nl.Id);
        }
        return result;
    }
    
    /**
     * Queries all the available user perms from the permission set object.  Makes
     * use of getUserPermLabels, which uses Apex Describe to get the set of available
     * user perms.  This is used to construct a dynamic SOQL query.
     */
    private List<SObject> queryUserPerms(List<Id> psIds) {
        String soql = 'SELECT Id';
        for (NameLabel nl : getUserPermLabels()) {
            soql += ', ' + nl.apiName;
        }
        soql += ' FROM PermissionSet WHERE Id IN :psIds';
        return Database.query(soql);
    }

    /**
     * Computes the API Name and Label information for the set of business objects available
     * to the organization
     */
    public List<NameLabel> getObjectLabels() {
        if (null == xObjectLabels) {
            List<NameLabel> result = new List<NameLabel>();
            Map<String,SObjectType> describe = Schema.getGlobalDescribe();

            // We can't really depend on describe to give us the object we want
            // since that includes a lot of stuff that doesn't support CRUD
            // or other supporting bits of metadata.  We're really just interested
            // in business data, so we'll rely on the set of object perms from
            // the system administrator profile to tell us what those objects are.
            //
            // Note: this is likely not a viable long-term solution, but it works
            // for now.                   
            for (ObjectPermissions op : [SELECT SObjectType FROM ObjectPermissions 
                                          WHERE Parent.Profile.Name = 'System Administrator']) {
                result.add(new NameLabel(op.SObjectType, 
                                         describe.get(op.SObjectType).getDescribe().getLabel()));
            }
            result.sort();
            xObjectLabels = result;
        }
        return xObjectLabels;
    }
    
    /**
     * List of object perm API Names, in the order we wish them displayed
     */
    public List<String> getObjectPermFieldNames() {
        return new String[] { CREATE, READ, EDIT, DELET, VAR, MAR }; 
    }

    /**
     * 
     */
    public MapHolder getObjectPermStatus() {
        if (null == xObjectStatus) {
            Map<String,Boolean> msb = new Map<String, Boolean>();
            for (NameLabel nl : getObjectLabels()) {
                // Converts total access into our MapHolder data structure.
                msb.put(nl.apiName,
                        getWithDefault(getObjectPerms().get(null).get(nl.apiName), READ, false)); 
            }
            xObjectStatus = new MapHolder(msb);
        }
        return xObjectStatus;
    }
    
    /**
     * Computes the set of object permissions for all permsets assigned to the user,
     * including the user's total access
     */
    public Map<Id,Map<String,ObjectPermissions>> getObjectPerms() {
        if (null == xObjectPerms) {
            Map<Id,Map<String,ObjectPermissions>> result = new Map<Id,Map<String,ObjectPermissions>>();

            // Ensure that each permset and object has an entry in our map structure
            for (NameLabel ps : permsetInfo) {
            	result.put(ps.Id, new Map<String,ObjectPermissions>());
                for (NameLabel op : getObjectLabels()) {
                	result.get(ps.Id).put(op.apiName, new ObjectPermissions());
                }
            }
            
            // Create a record for total access and also make sure that it has
            // an ObjectPermissions entry for every object.
            Map<String,ObjectPermissions> totalAccess = new Map<String,ObjectPermissions>();
            result.put(null, totalAccess);
            for (NameLabel op : getObjectLabels()) {
            	totalAccess.put(op.apiName, new ObjectPermissions());
            }
            
            // Retrieve the set of ObjectPermissions in our permission sets and use
            // that to populate our result 
            for (ObjectPermissions op : [SELECT Id, SObjectType, ParentId, 
                                                PermissionsCreate, PermissionsRead, PermissionsEdit, PermissionsDelete,
                                                PermissionsViewAllRecords, PermissionsModifyAllRecords 
                                           FROM ObjectPermissions
                                          WHERE ParentId IN :extractPsIds(permsetInfo)]) {
                Map<String,ObjectPermissions> opMap = result.get(op.ParentId);
                opMap.put(op.SObjectType, op);
                ObjectPermissions totalOp = totalAccess.get(op.SObjectType);
                for (String apiName : getObjectPermFieldNames()) {
                    totalOp.put(apiName, getWithDefault(totalOp, apiName, false) || getWithDefault(op, apiName, false));
                }
            }
            
            xObjectPerms = result;
        }
        return xObjectPerms;
    }

    /**
     * Returns the set of FLS settings we're interested in, in the order we wis to display them
     */    
    public List<String> getFlsPermFieldNames() {
        return new String[] { READ, EDIT };
    } 
    
    /**
     * Computes the list of fields.  NOTE: there is a subtle bug in here.  Because it uses
     * describe, it will return the set of fields available to the viewing user, not the user
     * in question.  There isn't a good way around this, as far as I know.  In reality, this
     * shouldn't be much of an issue here since a user won't have FieldPermissions assigned
     * for fields they do not have access to
     */
    public List<NameLabel> getFieldLabels() {
        if (null == flsObjectType) return null; 
        if (null == xFieldLabels) {
            List<NameLabel> result = new List<NameLabel>();
            Map<String, Schema.SObjectField> fmap = Schema.getGlobalDescribe().get(flsObjectType).getDescribe().fields.getMap();
            for (String key : fmap.keySet()) {
                result.add(new NameLabel(key, fmap.get(key).getDescribe().getLabel()));
            }
            result.sort();
            xFieldLabels = result;
        }
        return xFieldLabels;
    }

    /**
     * This is the action invoked by the VisualForce actionFunction.
     */
    public void loadFls() {
        // Nothing to do here.  The action call her sets flsObjectType, and getFls() does the loading lazily.
    }
    
    /**
     * Computes the set of FLS information for display, including total access calculation
     */
    public Map<Id,Map<String,FieldPermissions>> getFls() {
        if (null == xFls) {
            Map<Id,Map<String,FieldPermissions>> result = new Map<Id,Map<String,FieldPermissions>>();
            Set<Id> psIds = new Set<Id>();

            for (NameLabel ps : permsetInfo) {
                result.put(ps.Id, new Map<String,FieldPermissions>());
                psIds.add(ps.Id);
            }

            for (FieldPermissions fp : [SELECT ParentId, SObjectType, Field, PermissionsRead, PermissionsEdit
                                          FROM FieldPermissions
                                         WHERE ParentId IN :psIds
                                           AND SObjectType = :flsObjectType]) {
                if (!fp.Field.startsWith(fp.SObjectType + '.')) continue;                       
                String fName = fp.Field.substring(fp.SObjectType.length() + 1).toLowerCase();
                result.get(fp.ParentId).put(fName, fp);
                if (!result.get(null).containsKey(fName)) {
                    result.get(null).put(fName, fp.clone(false));
                } else {
                    FieldPermissions tot = result.get(null).get(fName);
                    tot.PermissionsEdit |= fp.PermissionsEdit;
                    tot.PermissionsRead |= fp.PermissionsRead;
                }
            }

            // Some fields do not support FLS, but the user is considered to have
            // certain permissions on them.  These settings are controlled by
            // something other than FLS, but for the purposes of this exercise,
            // these settings are included in the user's total access.  NOTE:
            // because we use describe, the information is returned as appropriate
            // for the viewing user, not the user under scrutiny.  As such, the
            // information may be subtly incorrect.  Caveat Emptor.
            Map<String, Schema.SObjectField> fmap = Schema.getGlobalDescribe().get(flsObjectType).getDescribe().fields.getMap();
            for (String key : fmap.keySet()) {
                DescribeFieldResult fDesc = fmap.get(key).getDescribe();
                if (!fDesc.isPermissionable()) {
                    result.get(null).put(fDesc.getName().toLowerCase(), new FieldPermissions(
                        PermissionsRead = fDesc.isAccessible(),
                        PermissionsEdit = fDesc.isUpdateable()
                    ));
                }
            }
            xFls = result;
        }
        return xFls;
    }

    public MapHolder getFieldStatus() {
        if (null == xFieldStatus) {
            Map<String,Boolean> msb = new Map<String,Boolean>();
            for (NameLabel nl : getFieldLabels()) {
                for (NameLabel ps : permsetInfo) {
                    if (!getFls().get(ps.Id).containsKey(nl.apiName)) {
                        getFls().get(ps.Id).put(nl.apiName, new FieldPermissions());
                    }
                }
                msb.put(nl.apiName, getFls().get(null).get(nl.apiName).PermissionsRead);
            }
            xFieldStatus = new MapHolder(msb);
        }
        return xFieldStatus;
    }
    
    /**
     * Computes the list of classes available in the org
     */
    public List<NameLabel> getClassNames() {
        if (null == xClassNames) {
            List<NameLabel> result = new List<NameLabel>();
            for (ApexClass ac : [SELECT Id, Name FROM ApexClass]) {
                result.add(new NameLabel(ac.Id, ac.Name, ac.Name));
            }
            result.sort();
            xClassNames = result;
        }
        return xClassNames;
    }

    /**
     * Computes which Apex Classes are available per permset
     */
    public Map<Id,Map<String,Boolean>> getApexClasses() {
        if (null == xApexClasses) {
           xApexClasses = calculateSetupEntityAccess('ApexClass', getClassNames());
        }
        return xApexClasses;
    }
    
    public MapHolder getClassStatus() {
        return new MapHolder(getApexClasses().get(null));
    }
    
    /**
     * Computes which Visual Force pages are present in the org
     */
    public List<NameLabel> getPageNames() {
        if (null == xPageNames) {
            List<NameLabel> result = new List<NameLabel>();
            for (ApexPage ap : [SELECT Id, Name FROM ApexPage]) {
                result.add(new NameLabel(ap.Id, ap.Name, ap.Name));
            }
            result.sort();
            xPageNames = result;
        }
        return xPageNames;
    }

    public Map<Id,Map<String,Boolean>> getPages() {
        if (null == xPages) {
           xPages = calculateSetupEntityAccess('ApexPage', getPageNames());
        }
        return xPages;
    }
    
    public MapHolder getPageStatus() {
        return new MapHolder(getPages().get(null));
    }

    /**
     * Both ApexClass and ApexPage access settings are stored as SetupEntityAccess objects.  As such,
     * they can easily be processed using common logic with some variables used to account for
     * differences
     */    
    private Map<Id,Map<String,Boolean>> calculateSetupEntityAccess(String seaType, List<NameLabel> seaNames) {
        Map<Id,Map<String,Boolean>> result = new Map<Id,Map<String,Boolean>>();
        Map<Id,String> seaMap = new Map<Id,String>();

        Map<String,Boolean> total = new Map<String,Boolean>();
        result.put(null, total);

        // Queries all the SetupEntityAccess objects of the appropriate type, and adds
        // the info to the result datastructure
        Map<Id,Set<Id>> enabledByPermset = new Map<Id,Set<Id>>();            
        for (SetupEntityAccess sea : [SELECT ParentId, SetupEntityId
                                        FROM SetupEntityAccess
                                       WHERE SetupEntityType = :seaType]) {
            Set<Id> enabled = enabledByPermset.get(sea.ParentId);
            if (null == enabled) {
                enabled = new Set<Id>();
                enabledByPermset.put(sea.ParentId, enabled);
            }
            enabled.add(sea.SetupEntityId);
        }

        // Ensure that each permset and setup entity has a row in our result datastructure.  This
        // keeps VisualForce happy when it does Map processing. 
        for (NameLabel ps : permsetInfo) {
        	if (null != ps.Id) {
                Map<String,Boolean> seaStatus = result.get(ps.Id);
                if (null == seaStatus) {
                    seaStatus = new Map<String,Boolean>();
                    result.put(ps.Id, seaStatus);
                }
                for (NameLabel nl : seaNames) {
                	boolean hasSea = enabledByPermset.containsKey(ps.Id) && enabledByPermset.get(ps.Id).contains(nl.id);
                    seaStatus.put(nl.apiName, hasSea);
                    if (hasSea || !total.containsKey(nl.apiName)) total.put(nl.apiName, hasSea);
                }
        	}
        }
        
        return result;
    }
}