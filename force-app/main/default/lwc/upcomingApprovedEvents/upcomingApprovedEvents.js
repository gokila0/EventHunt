import { LightningElement, wire } from 'lwc';
import getUpcomingApprovedEvents from '@salesforce/apex/EventController.getUpcomingApprovedEvents';
import getRegistrationCountForEvent from '@salesforce/apex/EventController.getRegistrationCountForEvent';

export default class UpcomingApprovedEvents extends LightningElement {
    events = [];
    loading = true;
    error;
    selectedEventId;
    selectedEventCount;
    counting = false;

    @wire(getUpcomingApprovedEvents)
    wiredEvents({ error, data }) {
        if (data) {
            // Map defensively in case fields are missing and include additional fields
            this.events = (data || []).map((evt) => {
                const dateVal = evt && evt.Event_Date__c ? new Date(evt.Event_Date__c) : null;
                const dateDisplay = dateVal
                    ? dateVal.toLocaleDateString(undefined, {
                          year: 'numeric',
                          month: 'short',
                          day: '2-digit'
                      })
                    : '';
                return {
                    id: evt && evt.Id,
                    name: (evt && evt.Name) || '',
                    dateDisplay,
                    venue: (evt && evt.Venue__c) || '',
                    type: (evt && evt.Event_Type__c) || '',
                    flyerUrl: (evt && evt.Event_Flyer_URL__c) || '',
                    registrationCount: undefined,
                    loadingCount: false
                };
            });
            this.error = undefined;
            this.loading = false;
            return;
        }
        if (error) {
            // Normalize Apex/AuraHandledException or network errors
            this.error =
                (error && error.body && error.body.message) ||
                (typeof error === 'string' ? error : JSON.stringify(error));
            this.loading = false;
            return;
        }
        // Fallback: no data and no error
        this.loading = false;
    }

    handleFlyerClick(event) {
        const url = event.currentTarget?.dataset?.url;
        if (url) {
            // Open in a new tab; rely on browser to block if disallowed
            window.open(url, '_blank', 'noopener,noreferrer');
        }
    }

    async handleCardClick(event) {
        // Event card container click handler (delegate from article)
        const id = event.currentTarget?.dataset?.id;
        if (!id) return;
        
        // Find the event in our events array
        const eventIndex = this.events.findIndex(evt => evt.id === id);
        if (eventIndex === -1) return;
        
        this.selectedEventId = id;
        this.selectedEventCount = undefined;
        this.counting = true;
        
        try {
            // Set loading state
            this.events[eventIndex].loadingCount = true;
            this.events[eventIndex].registrationCount = undefined;
            
            const count = await getRegistrationCountForEvent({ eventId: id });
            const parsedCount = typeof count === 'number' ? count : parseInt(count, 10);
            
            // Update the event object with registration count
            this.events[eventIndex].registrationCount = parsedCount;
            this.selectedEventCount = parsedCount;
        } catch (e) {
            // surface a friendly message; keep component resilient
            this.error =
                (e && e.body && e.body.message) ||
                (typeof e === 'string' ? e : JSON.stringify(e));
        } finally {
            this.events[eventIndex].loadingCount = false;
            this.counting = false;
        }
    }

    get hasEvents() {
        return Array.isArray(this.events) && this.events.length > 0;
    }

    get errorMessage() {
        return this.error || '';
    }

    get hasSelection() {
        return !!this.selectedEventId;
    }
}
