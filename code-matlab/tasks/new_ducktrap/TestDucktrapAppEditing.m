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
            limits = test.App.MainAxes.XLim;
            test.press(test.App.MainAxes, [limits(1)+0.1, 0]);
            test.verifyNumElements(findall(test.App.MainAxes, 'Type', 'ConstantLine'), 1);
            test.press(test.App.MainAxes, [limits(1)+0.2, 0], SelectionType='alt');
            test.verifyEmpty(findall(test.App.MainAxes, 'Type', 'ConstantLine'));
            test.press(test.App.MainAxes, [limits(1)+0.1, 0]);
            test.press(test.App.MainAxes, [limits(1)+0.2, 0]);
            test.verifyNumElements(findall(test.App.MainAxes, 'Type', 'ConstantLine'), 2);
            test.App.UIFigureWindowKeyPress(struct('Key', 'return'));
            test.verifyEqual(size(test.App.UITable.Data,1), 7);
            test.verifyEmpty(findall(test.App.MainAxes, 'Type', 'ConstantLine'));
        end
        function replaceAndDeleteDialogs(test)
            data = test.App.UITable.Data;
            test.press(test.App.MainAxes, [data(1,2)-0.02, 0]);
            test.press(test.App.MainAxes, [data(1,3)+0.02, 0]);
            test.chooseDialog('uiconfirm', test.App.UIFigure, ...
                @() test.App.UIFigureWindowKeyPress(struct('Key', 'return')), 'Cancel');
            test.verifyEqual(test.App.UITable.Data, data);
            test.chooseDialog('uiconfirm', test.App.UIFigure, ...
                @() test.App.UIFigureWindowKeyPress(struct('Key', 'return')), 'Replace');
            test.verifyEqual(test.App.UITable.Data(1,2:3), ...
                data(1,2:3)+[-0.02 0.02], 'AbsTol', 1e-8);
            test.chooseDialog('uiconfirm', test.App.UIFigure, ...
                @() test.App.UIFigureWindowKeyPress(struct('Key', 'delete')), 'Cancel');
            test.verifyEqual(size(test.App.UITable.Data,1), 6);
            test.chooseDialog('uiconfirm', test.App.UIFigure, ...
                @() test.App.UIFigureWindowKeyPress(struct('Key', 'backspace')), 'Delete');
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
    end
end
