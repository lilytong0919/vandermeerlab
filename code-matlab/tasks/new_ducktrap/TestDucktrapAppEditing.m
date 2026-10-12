classdef TestDucktrapAppEditing < matlab.uitest.TestCase
    properties
        App
    end
    methods (TestMethodSetup)
        function launch(test)
            test.App = demo_DucktrapApp();
            test.addTeardown(@() delete(test.App));
        end
    end
    methods (Test)
        function clicksCancelAndConfirm(test)
            test.press(test.App.BoundaryModeButton);
            limits = test.App.MainAxes.XLim;
            test.press(test.App.MainAxes, [limits(1)+0.1, 0]);
            test.verifyNumElements(findall(test.App.MainAxes, 'Type', 'ConstantLine'), 1);
            test.press(test.App.MainAxes, [limits(1)+0.2, 0], SelectionType='alt');
            test.verifyNumElements(findall(test.App.MainAxes, 'Type', 'ConstantLine'), 1);
            test.App.UIFigureWindowKeyPress(struct('Key', 's'));
            test.verifyEmpty(findall(test.App.MainAxes, 'Type', 'ConstantLine'));
            test.press(test.App.MainAxes, [limits(1)+0.1, 0]);
            test.press(test.App.MainAxes, [limits(1)+0.2, 0]);
            test.verifyNumElements(findall(test.App.MainAxes, 'Type', 'ConstantLine'), 2);
            test.press(test.App.MainAxes, [limits(1)+0.2, 0], SelectionType='alt');
            test.verifyEqual(size(test.App.UITable.Data,1), 7);
            test.verifyEmpty(findall(test.App.MainAxes, 'Type', 'ConstantLine'));
        end
        function replaceAndDeleteDialogs(test)
            test.press(test.App.BoundaryModeButton);
            data = test.App.UITable.Data;
            test.press(test.App.MainAxes, [data(1,2)-0.02, 0]);
            test.press(test.App.MainAxes, [data(1,3)+0.02, 0]);
            test.chooseDialog('uiconfirm', test.App.UIFigure, ...
                @() test.press(test.App.MainAxes, [mean(test.App.MainAxes.XLim),0], ...
                SelectionType='alt'), 'Cancel');
            test.verifyEqual(test.App.UITable.Data, data);
            test.verifyTrue(test.App.BoundaryModeButton.Value);
            test.chooseDialog('uiconfirm', test.App.UIFigure, ...
                @() test.press(test.App.MainAxes, [mean(test.App.MainAxes.XLim),0], ...
                SelectionType='alt'), 'Replace');
            test.verifyEqual(test.App.UITable.Data(1,2:3), ...
                data(1,2:3)+[-0.02 0.02], 'AbsTol', 1e-8);
            test.verifyFalse(test.App.BoundaryModeButton.Value);
            test.chooseDialog('uiconfirm', test.App.UIFigure, ...
                @() test.press(test.App.MainAxes, [mean(test.App.MainAxes.XLim),0], ...
                SelectionType='alt'), 'Cancel');
            test.verifyEqual(size(test.App.UITable.Data,1), 6);
            test.chooseDialog('uiconfirm', test.App.UIFigure, ...
                @() test.press(test.App.MainAxes, [mean(test.App.MainAxes.XLim),0], ...
                SelectionType='alt'), 'Delete');
            test.verifyEqual(size(test.App.UITable.Data,1), 5);
            test.verifyEqual(test.App.UITable.Selection, 1);
        end
        function saveAllRemainingEvents(test)
            filename = [tempname '.mat'];
            test.addTeardown(@() delete(filename));
            test.chooseDialog('uiputfile', @() test.App.SaveButtonPushed([]), File=filename);
            loaded = load(filename, 'evt');
            test.verifyEqual(loaded.evt.tstart, test.App.UITable.Data(:,2));
            test.verifyEqual(loaded.evt.tend, test.App.UITable.Data(:,3));
        end
        function scrollWindowPreservesSelection(test)
            before = test.App.MainAxes.XLim;
            test.scroll(test.App.MainAxes, 'down');
            test.verifyEqual(test.App.MainAxes.XLim, ...
                before + 0.2*diff(before), 'AbsTol', 1e-10);
            test.verifyEqual(test.App.UITable.Selection, 1);
            test.App.UIFigureWindowScrollWheel(struct('VerticalScrollCount', 3));
            test.verifyEqual(test.App.UITable.Selection, 1);
            test.verifyEqual(test.App.SegmentNumberSpinner.Value, 1);
            bounds = getpixelposition(test.App.SaveButton, true);
            test.hover(test.App.UIFigure, bounds(1:2)+bounds(3:4)/2);
            before = test.App.MainAxes.XLim;
            test.App.UIFigureWindowScrollWheel(struct('VerticalScrollCount', 1));
            test.verifyEqual(test.App.MainAxes.XLim, before);
        end
        function viewingClickAndBoundaryShortcut(test)
            data = test.App.UITable.Data;
            limits = test.App.MainAxes.XLim;
            test.press(test.App.MainAxes, [limits(1)+0.01, 0]);
            test.verifyEmpty(test.App.UITable.Selection);
            test.press(test.App.MainAxes, [mean(data(1,2:3)), 0]);
            test.verifyEqual(test.App.UITable.Selection, 1);
            test.verifyEqual(test.App.MainAxes.XLim, limits);
            test.App.UIFigureWindowKeyPress(struct('Key','s'));
            test.verifyTrue(test.App.BoundaryModeButton.Value);
            test.hover(test.App.MainAxes, [limits(1)+0.1, 0]);
            test.verifyNotEmpty(findall(test.App.MainAxes,'Type','Patch','FaceAlpha',0.25));
            test.App.UIFigureWindowKeyPress(struct('Key','q'));
            test.verifyFalse(test.App.BoundaryModeButton.Value);
            bounds = getpixelposition(test.App.MinFrequencyEditField,true);
            test.press(test.App.UIFigure, bounds(1:2)+bounds(3:4)/2);
            test.App.UIFigureWindowKeyPress(struct('Key','s'));
            test.verifyFalse(test.App.BoundaryModeButton.Value);
        end
        function spaceResetAndTitleStates(test)
            before = test.App.MainAxes.XLim;
            test.scroll(test.App.MainAxes,'down');
            test.App.UIFigureWindowKeyPress(struct('Key','space'));
            test.verifyEqual(test.App.MainAxes.XLim,before,'AbsTol',1e-10);
            test.verifyEqual(test.App.MainAxes.Title.String,'Viewing');
            test.App.UIFigureWindowKeyPress(struct('Key','s'));
            test.verifyEqual(test.App.MainAxes.Title.String,'Set Boundaries: Select Start');
            test.press(test.App.MainAxes,[before(1)+0.1,0]);
            test.verifyEqual(test.App.MainAxes.Title.String,'Set Boundaries: Select End');
            test.press(test.App.MainAxes,[before(1)+0.2,0]);
            test.verifyEqual(test.App.MainAxes.Title.String,'Set Boundaries: Ready to Confirm');
            test.App.UIFigureWindowKeyPress(struct('Key','return'));
            test.verifyEqual(size(test.App.UITable.Data,1),6);
            test.App.UIFigureWindowKeyPress(struct('Key','q'));
            test.verifyFalse(test.App.BoundaryModeButton.Value);
            test.verifyEmpty(findall(test.App.MainAxes,'Type','ConstantLine'));
        end
        function boundaryModeIsolatesViewingActions(test)
            data = test.App.UITable.Data;
            limits = test.App.MainAxes.XLim;
            test.press(test.App.BoundaryModeButton);
            test.verifyEmpty(test.App.UITable.Selection);
            test.verifyEqual(test.App.UITable.Enable,'off');
            test.verifyEqual(test.App.SegmentNumberSpinner.Enable,'off');
            test.verifyEqual(test.App.TeleportButton.Enable,'off');
            test.verifyEqual(test.App.SaveButton.Enable,'off');
            test.verifyEqual(test.App.QuitButton.Enable,'off');
            test.verifyEqual(test.App.WindowSizeSpinner.Enable,'on');
            test.App.SegmentNumberSpinnerValueChanged(struct('Value',3));
            test.App.UITableSelectionChanged(struct('Selection',3));
            test.App.TeleportButtonPushed([]);
            test.App.SaveButtonPushed([]);
            test.App.QuitButtonPushed([]);
            test.App.UIFigureWindowKeyPress(struct('Key','space'));
            test.verifyEqual(test.App.MainAxes.XLim,limits);
            test.verifyEqual(test.App.UITable.Data,data);
            test.verifyEmpty(test.App.UITable.Selection);
            test.App.UIFigureWindowKeyPress(struct('Key','q'));
            test.verifyEqual(test.App.UITable.Enable,'on');
            test.verifyEqual(test.App.SaveButton.Enable,'on');
            test.verifyEmpty(test.App.UITable.Selection);
        end
    end
end
