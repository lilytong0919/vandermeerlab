function app = demo_DucktrapApp()
%DEMO_DUCKTRAPAPP Launch DucktrapApp with reproducible synthetic data.

[cfg, S, CSC] = generateDucktrapMockData();
app = DucktrapApp(cfg, S, CSC);
end
