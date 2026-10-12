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
        function scrollPreservesWidthAndCancelsPending(test)
            test.Session.selectBoundary(2.1);
            test.Session.scrollTime(1);
            test.verifyEqual(test.Session.CurrentTime, 2.9, 'AbsTol', 1e-12);
            test.verifyEqual(test.Session.WindowSize, 2);
            test.verifyEmpty(test.Session.FirstBoundary);
            test.verifyFalse(test.Session.HasUnsavedChanges);
            test.Session.scrollTime(-1);
            test.verifyEqual(test.Session.CurrentTime, 2.5, 'AbsTol', 1e-12);
        end
        function scrollPreservesEventData(test)
            intervals = test.Session.SuggestedIntervals;
            test.Session.scrollTime(4);
            test.verifyEqual(test.Session.CurrentTime, 4.1, 'AbsTol', 1e-12);
            test.Session.scrollTime(6);
            test.verifyEqual(test.Session.SuggestedIntervals, intervals);
            test.verifyFalse(test.Session.HasUnsavedChanges);
        end
        function scrollClampsRecordingEdges(test)
            test.Session.scrollTime(100);
            [left, right] = test.Session.viewLimits();
            test.verifyEqual([left right], [8 10]);
            test.Session.scrollTime(-100);
            [left, right] = test.Session.viewLimits();
            test.verifyEqual([left right], [0 2]);
        end
        function boundaryModeRestartAndConfirm(test)
            test.Session.setBoundaryMode(true);
            test.Session.selectBoundary(7);
            test.Session.selectBoundary(6);
            test.Session.cancelSelection();
            test.verifyEmpty(test.Session.FirstBoundary);
            test.verifyEmpty(test.Session.PendingInterval);
            test.verifyTrue(test.Session.BoundaryMode);
            test.Session.selectBoundary(6);
            test.Session.selectBoundary(7);
            test.Session.confirmPending(true);
            test.verifyFalse(test.Session.BoundaryMode);
        end
        function boundaryModeExitAndScroll(test)
            test.Session.setBoundaryMode(true);
            test.Session.selectBoundary(6);
            test.Session.scrollTime(1);
            test.verifyTrue(test.Session.BoundaryMode);
            test.verifyEqual(test.Session.FirstBoundary, 6);
            test.Session.selectBoundary(6);
            test.Session.setBoundaryMode(false);
            test.verifyEmpty(test.Session.FirstBoundary);
            test.verifyFalse(test.Session.BoundaryMode);
        end
        function hitExistingEvent(test)
            test.verifyEqual(test.Session.eventAtTime(2.5), 1);
            test.verifyEqual(test.Session.eventAtTime(4.5), 2);
            test.verifyEmpty(test.Session.eventAtTime(6));
        end
        function temporaryZoomAndReset(test)
            test.Session.zoomTime(-1);
            test.verifyEqual(test.Session.WindowSize, 2);
            test.verifyEqual(test.Session.DisplayWindowSize, 1.6, 'AbsTol', 1e-12);
            test.verifyEqual(test.Session.CurrentTime, 2.5);
            [left, right] = test.Session.viewLimits();
            test.verifyEqual([left right], [1.7 3.3], 'AbsTol', 1e-12);
            test.Session.resetZoom();
            test.Session.teleportToSuggestedSWR(2);
            test.verifyEqual(test.Session.CurrentTime, 4.5);
            test.verifyEqual(test.Session.DisplayWindowSize, 2);
            test.Session.zoomTime(1);
            test.Session.resetZoom();
            test.verifyEqual(test.Session.CurrentTime, 4.5);
            test.verifyEqual(test.Session.DisplayWindowSize, 2);
        end
        function panUsesTemporarySpan(test)
            test.Session.zoomTime(-1);
            test.Session.scrollTime(1);
            test.verifyEqual(test.Session.CurrentTime, 2.82, 'AbsTol', 1e-12);
            test.verifyEqual(test.Session.WindowSize, 2);
            test.Session.changeWindowSize(3);
            test.verifyEqual(test.Session.DisplayWindowSize, 3);
        end
        function zoomLimitsAndPendingBoundaries(test)
            test.Session.selectBoundary(2.2);
            test.Session.zoomTime(100);
            test.verifyEqual(test.Session.DisplayWindowSize, 10);
            test.verifyEqual(test.Session.FirstBoundary, 2.2);
            test.Session.zoomTime(-100);
            test.verifyEqual(test.Session.DisplayWindowSize, 0.001);
            test.verifyFalse(test.Session.HasUnsavedChanges);
        end
        function centerPendingBoundaries(test)
            test.Session.setBoundaryMode(true);
            test.Session.centerBoundaries();
            test.verifyEqual(test.Session.CurrentTime, 2.5);
            test.Session.selectBoundary(6);
            test.Session.centerBoundaries();
            test.verifyEqual(test.Session.CurrentTime, 6);
            test.Session.selectBoundary(7);
            test.Session.centerBoundaries();
            test.verifyEqual(test.Session.CurrentTime, 6.5);
            test.verifyEqual(test.Session.PendingInterval, [6 7]);
        end
        function boundaryNavigationPreservesData(test)
            events = test.Session.SuggestedIntervals;
            test.Session.setBoundaryMode(true);
            test.Session.selectBoundary(6);
            test.Session.selectBoundary(7);
            test.Session.scrollTime(1);
            test.Session.zoomTime(-1);
            test.Session.resetZoom();
            test.Session.centerBoundaries();
            test.verifyEqual(test.Session.PendingInterval, [6 7]);
            test.verifyEqual(test.Session.SuggestedIntervals, events);
            test.verifyFalse(test.Session.HasUnsavedChanges);
            test.verifyTrue(test.Session.BoundaryMode);
        end
    end
end
