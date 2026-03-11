/* eslint-disable no-unused-vars */
const { createElement } = require('lwc');
const UpcomingApprovedEvents = require('c/upcomingApprovedEvents').default;

// Basic smoke test to ensure component renders without crashing
describe('c-upcoming-approved-events', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it('renders header title', async () => {
    const element = createElement('c-upcoming-approved-events', {
      is: UpcomingApprovedEvents
    });
    document.body.appendChild(element);

    // Allow any microtasks to complete
    await Promise.resolve();

    const title = element.shadowRoot.querySelector('.slds-text-heading_small');
    expect(title).not.toBeNull();
    expect(title.textContent).toContain('Upcoming Approved Events');
  });

  it('initially shows loading spinner', async () => {
    const element = createElement('c-upcoming-approved-events', {
      is: UpcomingApprovedEvents
    });
    document.body.appendChild(element);

    const spinner = element.shadowRoot.querySelector('lightning-spinner');
    expect(spinner).not.toBeNull();
  });
});
