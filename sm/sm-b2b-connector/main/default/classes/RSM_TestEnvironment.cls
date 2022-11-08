@IsTest
public class RSM_TestEnvironment {

    public static final PermissionSets PERMISSION_SETS = new PermissionSets();
    public static final Profiles PROFILES = new Profiles();

    public static User portalAccountOwner {
        get {
            if (portalAccountOwner == null) {
                portalAccountOwner = getPortalAccountOwnerInstance();
            }

            return portalAccountOwner;
        }
        private set;
    }

    public static UserRole portalRole {
        get {
            if (portalRole == null) {
                portalRole = getPortalRoleInstance();
            }

            return portalRole;
        }
        private set;
    }

    private static User getPortalAccountOwnerInstance() {
        UserRole portalRole = portalRole;
        List<User> users = [
                SELECT Id
                FROM User
                WHERE Profile.Name = :B2B_Constants.Profile.SYSTEM_ADMIN
                AND UserRoleId = :portalRole.Id
        ];

        User portalAccountOwner;
        if (users.isEmpty()) {
            portalAccountOwner = createPortalUser();
            portalAccountOwner.UserRoleId = portalRole.Id;
            portalAccountOwner.ProfileId = PROFILES.getId(B2B_Constants.Profile.SYSTEM_ADMIN);
            insert portalAccountOwner;
        }
        else {
            portalAccountOwner = users.get(0);
        }
        return portalAccountOwner;
    }

    public static User createPortalAccountOwner() {
        return getPortalAccountOwnerInstance();
    }

    private static UserRole getPortalRoleInstance() {
        List<UserRole> userRoles = [
                SELECT Id
                FROM UserRole
                WHERE Name = :B2B_Constants.UserRole.RSM_PORTAL_OWNER_ROLE_NAME
        ];

        UserRole portalRole;
        if (userRoles.isEmpty()) {
            portalRole = new UserRole(DeveloperName = B2B_Constants.UserRole.RSM_PORTAL_OWNER_ROLE_DEVELOPER_NAME, Name = B2B_Constants.UserRole.RSM_PORTAL_OWNER_ROLE_NAME, PortalType='None');
            insert portalRole;
        }
        else {
            portalRole = userRoles.get(0);
        }
        return portalRole;
    }

    public static UserRole createPortalRole() {
        return getPortalRoleInstance();
    }

    public static void assignPermissionSet(User user, String permissionSetName) {
        insert new PermissionSetAssignment(
                AssigneeId = user.Id,
                PermissionSetId = PERMISSION_SETS.getId(permissionSetName)
        );
    }

    public static User createPortalUser() {
        User portalAccountOwner = new User(
            FirstName = 'Portal',
            Lastname = 'Owner',
            Username = 'portalOwner' + System.currentTimeMillis() + '@test.com',
            Alias = 'POwner',
            EmailEncodingKey = 'ISO-8859-1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            CommunityNickname = System.currentTimeMillis() + '_' + 'nick1',
            IsActive = true,
            PortalRole = 'Manager',
            Email = 'portal.owner@test.com'
        );
        return portalAccountOwner;
    }

    public class PermissionSets {
        @TestVisible
        Map<String, Id> permissionSetIdByName {
            get {
                if (permissionSetIdByName == null) {
                    permissionSetIdByName = new Map<String, Id>();
                    for (PermissionSet permissionSet : [
                        SELECT Id, Label, Name
                        FROM PermissionSet
                        WHERE ProfileId = null]) {
                        permissionSetIdByName.put(permissionSet.Name.toUpperCase(), permissionSet.Id);
                        permissionSetIdByName.put(permissionSet.Label.toUpperCase(), permissionSet.Id);
                    }
                }
                return permissionSetIdByName;
            }
            set;
        }

        public Id getId(String name) {
            return permissionSetIdByName.get(name.toUpperCase());
        }

        public List<Id> getIds(List<String> names) {
            List<Id> ids = new List<Id>();
            for (String name : names) {
                Id id = this.getId(name);
                if (id != null) {
                    ids.add(id);
                }
            }
            return ids;
        }
    }

    public class Profiles {
        @TestVisible
        Map<String, Id> profileIdByName {
            get {
                if (profileIdByName == null) {
                    profileIdByName = new Map<String, Id>();
                    for (Profile profile : [SELECT Id, Name FROM Profile]) {
                        profileIdByName.put(profile.Name.toUpperCase(), profile.Id);
                    }
                }
                return profileIdByName;
            }
            set;
        }

        public Id getId(String name) {
            return profileIdByName.get(name.toUpperCase());
        }
    }

}