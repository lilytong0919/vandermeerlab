classdef TestDucktrapNavigation < matlab.unittest.TestCase
    properties
        Session
    end
    methods (TestMethodSetup)
        function setup(test)
            centers = (10:2:168)';
            cfg = struct('evt',iv(centers-0.1,centers+0.1),'windowSize',4);
            csc = struct('tvec',0:200,'data',zeros(1,201));
            test.Session = DucktrapSession(cfg,struct('t',{{}}),csc);
        end
    end
    methods (Test)
        function adjacentFromCenteredEvent(test)
            test.Session.teleportToSuggestedSWR(2);
            test.verifyEqual(test.Session.eventNavigationTarget(-1,1),1);
            test.verifyEqual(test.Session.eventNavigationTarget(1,1),3);
        end
        function adjacentFromBetweenEvents(test)
            test.Session.scrollTime(2);
            test.verifyEqual(test.Session.CurrentTime,11.6,'AbsTol',1e-12);
            test.verifyEqual(test.Session.eventNavigationTarget(-1,1),1);
            test.verifyEqual(test.Session.eventNavigationTarget(1,1),2);
            test.verifyEqual(test.Session.eventNavigationTarget(1,10),12);
            test.verifyEqual(test.Session.eventNavigationTarget(1,50),52);
        end
        function jumpsTenAndFifty(test)
            test.Session.teleportToSuggestedSWR(40);
            test.verifyEqual(test.Session.eventNavigationTarget(-1,10),30);
            test.verifyEqual(test.Session.eventNavigationTarget(1,10),50);
            test.verifyEqual(test.Session.eventNavigationTarget(-1,50),1);
            test.verifyEqual(test.Session.eventNavigationTarget(1,50),80);
        end
        function midpointTieUsesLaterEvent(test)
            test.Session.scrollTime(1.25);
            test.verifyEqual(test.Session.CurrentTime,11);
            test.verifyEqual(test.Session.eventNavigationTarget(-1,1),1);
            test.verifyEqual(test.Session.eventNavigationTarget(1,1),2);
            test.verifyEqual(test.Session.eventNavigationTarget(1,10),12);
            test.verifyEqual(test.Session.eventNavigationTarget(1,50),52);
        end
        function recordingEdgesClamp(test)
            test.Session.scrollTime(-100);
            test.verifyEqual(test.Session.eventNavigationTarget(-1,1),1);
            test.verifyEqual(test.Session.eventNavigationTarget(1,1),1);
            test.Session.scrollTime(1000);
            test.verifyEqual(test.Session.eventNavigationTarget(-1,1),80);
            test.verifyEqual(test.Session.eventNavigationTarget(1,1),80);
        end
        function navigationPreservesTemporaryZoomAndData(test)
            events = test.Session.SuggestedIntervals;
            test.Session.zoomTime(-1);
            index = test.Session.eventNavigationTarget(1,10);
            test.Session.teleportToSuggestedSWR(index);
            test.verifyEqual(test.Session.DisplayWindowSize,3.2,'AbsTol',1e-12);
            test.verifyEqual(test.Session.WindowSize,4);
            test.verifyEqual(test.Session.SuggestedIntervals,events);
            test.verifyFalse(test.Session.HasUnsavedChanges);
        end
        function boundaryModeBlocksEventNavigation(test)
            test.Session.setBoundaryMode(true);
            test.Session.selectBoundary(11);
            test.verifyEmpty(test.Session.eventNavigationTarget(1,1));
            test.verifyEmpty(test.Session.eventNavigationTarget(-1,50));
            test.verifyEqual(test.Session.FirstBoundary,11);
            test.verifyEqual(test.Session.CurrentTime,10);
        end
        function emptyEventsAreInert(test)
            session = DucktrapSession(struct('evt',iv([],[])), ...
                test.Session.Spikes,test.Session.CSC);
            test.verifyEmpty(session.eventNavigationTarget(-1,1));
            test.verifyEmpty(session.eventNavigationTarget(1,50));
        end
    end
end
