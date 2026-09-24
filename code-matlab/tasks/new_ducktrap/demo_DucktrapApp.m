function app = demo_DucktrapApp()
%DEMO_DUCKTRAPAPP Launch DucktrapApp with reproducible synthetic data.

[cfg, S, CSC] = generateDucktrapMockData();
app = DucktrapApp();
ducktrapapp.initializeApp(app, cfg, S, CSC);
end
