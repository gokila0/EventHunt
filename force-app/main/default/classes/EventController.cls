public with sharing class EventController {
    /**
     * @description Returns upcoming approved events limited to 20, ordered by Event_Date__c.
     */
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getUpcomingApprovedEvents() {
        Date today = Date.today();
        try {
            List<Event__c> events = [
                SELECT Id, Name, Event_Date__c, Venue__c, Event_Type__c, Event_Flyer_URL__c
                FROM Event__c
                WHERE Status__c = 'Approved'
                  AND Event_Date__c >= :today
                ORDER BY Event_Date__c ASC
                LIMIT 20
            ];
            return events;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load upcoming approved events.');
        }
    }

    /**
     * @description Returns all events with required fields for portal table UI.
     * Fields: Id, Name, Status__c, Venue__c, Event_Date__c
     */
    @AuraEnabled(cacheable=true)
    public static List<Event__c> getAllEvents() {
        try {
            List<Event__c> events = [
                SELECT Id, Name, Status__c, Venue__c, Event_Date__c
                FROM Event__c
                ORDER BY Event_Date__c DESC, Name
            ];
            return events;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load events.');
        }
    }

    /**
     * @description Updates an Event__c record with the provided fields.
     */
    @AuraEnabled
    public static void updateEvent(Id eventId, String name, String location, String status) {
        try {
            Event__c evt = [SELECT Id FROM Event__c WHERE Id = :eventId LIMIT 1];
            if (name != null) {
                evt.Name = name;
            }
            if (location != null) {
                evt.Location__c = location;
            }
            if (status != null) {
                evt.Status__c = status;
            }
            update evt;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to update event: ' + e.getMessage());
        }
    }

    /**
     * @description Creates a new Event__c record.
     */
    @AuraEnabled
    public static Id createEvent(
        String name,
        String eventType,
        String description,
        Date eventDate,
        Date registrationDeadline,
        String location,
        String venue,
        Integer capacity,
        String status,
        String eventFlyerUrl,
        Id facultyOrganizerId,
        String participatingDepartment
    ) {
        try {
            Event__c evt = new Event__c();
            evt.Name = name;
            if (eventType != null) { evt.Event_Type__c = eventType; }
            if (description != null) { evt.Description__c = description; }
            if (eventDate != null) { evt.Event_Date__c = eventDate; }
            if (registrationDeadline != null) { evt.Registration_Deadline__c = registrationDeadline; }
            if (location != null) { evt.Location__c = location; }
            if (venue != null) { evt.Venue__c = venue; }
            if (capacity != null) { evt.Capacity__c = capacity; }
            if (status != null) { evt.Status__c = status; }
            if (eventFlyerUrl != null) { evt.Event_Flyer_URL__c = eventFlyerUrl; }
            if (facultyOrganizerId != null) { evt.Faculty_Organizer__c = facultyOrganizerId; }
            if (participatingDepartment != null) { evt.Participating_Department__c = participatingDepartment; }
            insert evt;
            return evt.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to create event: ' + e.getMessage());
        }
    }

    /**
     * @description Returns Faculty records for the lookup field.
     */
    @AuraEnabled(cacheable=true)
    public static List<Faculty__c> getFacultyList() {
        try {
            return [SELECT Id, Name FROM Faculty__c ORDER BY Name ASC LIMIT 200];
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load faculty list.');
        }
    }

    /**
     * @description Returns the number of Registration__c child records for a given Event__c.
     * Expects Registration__c to have a lookup field Event__c to the parent event.
     */
    @AuraEnabled(cacheable=true)
    public static Integer getRegistrationCountForEvent(Id eventId) {
        try {
            if (eventId == null) {
                throw new AuraHandledException('Missing eventId.');
            }
            // Aggregate to count registrations by Event__c
            // Added explicit field reference check and better error handling
            try {
                List<AggregateResult> agg = [
                    SELECT COUNT(Id) cnt
                    FROM Registration__c
                    WHERE Event__c = :eventId
                ];
                if (!agg.isEmpty()) {
                    Object v = agg[0].get('cnt');
                    return (v instanceof Integer) ? (Integer)v : Integer.valueOf(String.valueOf(v));
                }
            } catch (Exception e) {
                // Enhanced error handling to provide more context
                System.debug('Error in getRegistrationCountForEvent: ' + e.getMessage());
                throw new AuraHandledException('Unable to load registration count: ' + e.getMessage());
            }
            return 0;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load registration count.');
        }
    }
}
