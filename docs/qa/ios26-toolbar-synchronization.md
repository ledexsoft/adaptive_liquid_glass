# iOS 26 toolbar synchronization: validation boundary

This record concerns the Dart/platform-channel bridge, not a physical UIKit or
VoiceOver session. Tests use synthetic actions and do not delete real data.

## Reproduced regressions

- A platform view created with a Refresh action retained that initial payload
  when Flutter changed to Delete before native creation completed. No catch-up
  update was sent; an index-zero callback invoked the new Delete handler.
- A title-only context change with identical action objects allowed the new
  handler to run while the old contextual title's update was still pending.

`test/ios26_toolbar_creation_race_test.dart` retains creation and individual
method acknowledgements to reproduce these windows deterministically.

## Contract

- Reconcile current brightness, actions, leading, effective title and tint
  after native creation. Do not treat current Flutter props as acknowledged
  creation parameters.
- Serialize updates and coalesce intervening rebuilds. Acknowledging an older
  item/context snapshot must not enable callbacks for its replacement.
- Reject callbacks while item/leading/title reconciliation is pending, after
  channel failure, and from hidden, replaced or disposed view channels.
- Preserve action names, source enabled states and navigation callbacks after
  successful synchronization. A title overlay clears the native title.

## Failure and accessibility limits

A channel error fails closed: native action and native-leading callbacks remain
blocked until a subsequent rebuild successfully synchronizes the current state.
There is deliberately no automatic retry loop or guarantee of autonomous
recovery. Flutter-rendered leading overlays are not handled by this native
callback gate.

The tests verify transmitted accessible names and disabled flags, including
recovery. They do not prove a native spoken failure announcement or that UIKit
visually marks a temporarily gated callback disabled: an unavailable channel
cannot be assumed to deliver such a state change. Physical accessibility and
recovery behavior still require device QA.

The existing native event protocol supplies an action index, not a snapshot
revision. The tests cover creation/update acknowledgement races and stale view
channels, not arbitrary reordering of an old same-view event delivered after a
new snapshot has been acknowledged. No stronger cross-direction ordering
or event-version guarantee is claimed.

## Verification scope

Focused regressions exercise delayed creation, updates during acknowledgement,
channel failure/rebuild recovery, hidden/recreated views, disposal, title-only
context changes, title overlays and disabled accessible actions. Existing
leading-text and accessibility suites must also pass. Run the complete package
suite and analyzer before publication; a successful compile or mock test is not
native interaction QA.
