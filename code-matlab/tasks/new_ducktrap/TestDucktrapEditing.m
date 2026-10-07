classdef TestDucktrapEditing < matlab.unittest.TestCase
    properties
        Session
    end
    methods (TestMethodSetup)
        function setup(test)
            cfg = struct('mode', 'unfixed', 'evt', iv([2; 4], [3; 5]), ...
                'hdr', struct('session', 'test'));
            csc = struct('tvec', 0:0.01:10, 'data', zeros(1,1001), 'label', {{'LFP'}});
            test.Session = DucktrapSession(cfg, struct('t', {{}}), csc);
        end
    end
    methods (Test)
        function reverseClicksAndCancel(test)
            test.Session.selectBoundary(7);
            test.Session.selectBoundary(6);
            test.verifyEqual(test.Session.PendingInterval, [6 7]);
            test.Session.cancelSelection();
            test.verifyEmpty(test.Session.PendingInterval);
            test.verifyEmpty(test.Session.FirstBoundary);
            test.verifyFalse(test.Session.HasUnsavedChanges);
        end
        function overlapRequiresConsent(test)
            test.Session.selectBoundary(2.5);
            test.Session.selectBoundary(4.5);
            test.verifyEqual(test.Session.pendingOverlaps(), [1; 2]);
            test.verifyEmpty(test.Session.confirmPending(false));
            test.verifyEqual(test.Session.SuggestedIntervals.tstart, [2; 4]);
            test.verifyEqual(test.Session.PendingInterval, [2.5 4.5]);
            test.verifyEqual(test.Session.confirmPending(true), 1);
            test.verifyEqual(test.Session.SuggestedIntervals.tstart, 2.5);
            test.verifyEqual(test.Session.SuggestedIntervals.tend, 4.5);
            test.verifyTrue(test.Session.ConfirmedMask);
        end
        function deleteAndExportAll(test)
            test.Session.selectBoundary(7);
            test.Session.selectBoundary(6);
            test.Session.confirmPending(true);
            test.Session.deleteEvent(2);
            evt = test.Session.exportEvents(true);
            test.verifyEqual(evt.tstart, [2; 6]);
            test.verifyEqual(evt.tend, [3; 7]);
            test.verifyEqual(evt.label, {'LFP'});
            test.verifyEqual(evt.hdr.session, 'test');
            test.verifyEqual(evt.cfg.history.mfun{end}, 'DucktrapApp');
            test.verifyTrue(test.Session.HasUnsavedChanges);
            test.Session.markSaved();
            test.verifyFalse(test.Session.HasUnsavedChanges);
        end
        function touchingIntervalsDoNotOverlap(test)
            test.Session.selectBoundary(3);
            test.Session.selectBoundary(4);
            test.verifyEmpty(test.Session.pendingOverlaps());
            test.Session.confirmPending(false);
            test.verifyEqual(test.Session.SuggestedIntervals.tstart, [2; 3; 4]);
        end
        function deleteLastEvent(test)
            test.Session.deleteEvent(2);
            test.Session.deleteEvent(1);
            evt = test.Session.exportEvents(true);
            test.verifyEmpty(evt.tstart);
            test.verifyEmpty(evt.tend);
        end
        function fixedAndResume(test)
            cfg = struct('mode', 'fixed', 'trapwin', 0.2, 'evt', iv(2,3), ...
                'resume', iv(2.2,2.4));
            csc = struct('tvec', 0:0.01:10, 'data', zeros(1,1001));
            session = DucktrapSession(cfg, struct('t', {{}}), csc);
            test.verifyEqual(session.SuggestedIntervals.tstart, 2.2);
            test.verifyTrue(session.ConfirmedMask);
            test.verifyFalse(session.HasUnsavedChanges);
            session.selectBoundary(6);
            test.verifyEqual(session.PendingInterval, [5.9 6.1], 'AbsTol', 1e-12);
        end
        function matFileRoundTrip(test)
            filename = [tempname '.mat'];
            test.addTeardown(@() delete(filename));
            evt = test.Session.exportEvents(true);
            save(filename, 'evt');
            loaded = load(filename, 'evt');
            test.verifyEqual(loaded.evt, evt);
        end
    end
end
