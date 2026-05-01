# Testing Path

## 1. Happy Path - First Launch (Online)

1. Run app on simulator with network enabled
2. **Expect**: Loading spinner appears briefly, then transaction list loads with 30 items
3. **Verify**: Each row shows counterparty name, amount, description, date, status badge, and operation icon

## 2. Pagination

1. Scroll down toward the bottom of the list
2. **Expect**: When ~5 items from the end, a loading spinner appears at the bottom
3. **Expect**: New transactions load and append to the list
4. **Verify**: No duplicate transactions appear
5. Keep scrolling to trigger multiple pages

## 3. Pull-to-Refresh

1. Pull down on the list from the top
2. **Expect**: Refresh indicator appears, list reloads from page 1
3. **Verify**: List updates (may look the same if API data hasn't changed)

## 4. No Internet Banner - Real-time Detection

1. Load the app online, let transactions appear
2. Turn off Wi-Fi / Enable Airplane Mode
3. **Expect**: Red "No Internet" banner slides in at the top instantly
4. Turn Wi-Fi back on / Disable Airplane Mode
5. **Expect**: Banner disappears instantly
6. **Verify**: Banner appears/disappears on ALL screens (loaded list, error view, loading)

## 5. Offline - With Cached Data

1. Load the app online first (so data gets cached)
2. Enable Airplane Mode
3. Kill and relaunch the app
4. **Expect**: Red "No Internet" banner at top
5. **Expect**: Previously loaded transactions still visible below the banner
6. **Verify**: No pagination (cached data only, `hasMorePages` is false)

## 6. Offline - No Cached Data (First Launch)

1. Delete the app (clear SwiftData store)
2. Enable Airplane Mode
3. Launch the app
4. **Expect**: Error view with message and "Try Again" button
5. **Expect**: Red "No Internet" banner visible at top alongside the error view
6. Tap "Try Again"
7. **Expect**: Still shows error (no network)
8. Disable Airplane Mode, tap "Try Again"
9. **Expect**: Transactions load normally, banner disappears

## 7. Pagination Failure (Silent)

1. Load the app online, let first page load
2. Turn off network
3. Scroll to bottom to trigger page 2
4. **Expect**: Pagination fails silently - no alert, no error row
5. **Expect**: Red "No Internet" banner visible at top
6. Turn network back on
7. **Expect**: Banner disappears
8. Scroll to bottom again
9. **Expect**: Page 2 loads successfully

## 8. Refresh Failure (Silent When Data Exists)

1. Load the app online, let first page load
2. Turn off network
3. Pull to refresh
4. **Expect**: Refresh completes silently - no alert, data stays on screen
5. **Expect**: Red "No Internet" banner visible at top
6. Turn network back on, pull to refresh
7. **Expect**: Refresh works, banner disappears

## 9. Edge Cases

| Scenario | What to check |
|----------|--------------|
| Rapid scrolling | No duplicate API calls (guard in `loadMoreTransactions`) |
| Pull-to-refresh mid-pagination | Resets cleanly to page 1 |
| Rotate device | Layout adapts, no data loss |
| Background/foreground | State preserved, no re-fetch |
| Large text (Accessibility) | Dynamic Type scales properly |
| Toggle Wi-Fi rapidly | Banner animates smoothly, no flicker |

## Quick Checklist

- [ ] App launches without crash
- [ ] First page loads (30 transactions)
- [ ] Rows display all required fields
- [ ] Pagination loads more on scroll
- [ ] No duplicate rows after pagination
- [ ] Pull-to-refresh works
- [ ] "No Internet" banner appears instantly when offline
- [ ] "No Internet" banner disappears instantly when back online
- [ ] Offline with cache shows banner + data
- [ ] Offline without cache shows error view + banner
- [ ] Error retry works
- [ ] Pagination fails silently when offline
- [ ] Refresh fails silently when data exists
