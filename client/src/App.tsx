import { useState, useEffect } from 'react';
import { LinearProgress, Typography, Grid } from '@mui/material';
import { createDockerDesktopClient } from '@docker/extension-api-client';
import { LazyLog,ScrollFollow } from "react-lazylog";

const client = createDockerDesktopClient();

function useDockerDesktopClient() {
  return client;
}


export function App() {
  const [ready, setReady] = useState<boolean>(false);
  const [logs, setLogs] = useState<string>("fetching logs...");
  const ddClient = useDockerDesktopClient();

  useEffect(() => {
    
      const checkIfOracleXEIsReady = async () => {
      const result = await ddClient.extension.vm?.service?.get('/ready');
      const ready = Boolean(result);
      if (ready) {
        clearInterval(timer);
      }
      setReady(ready);
      const xelog = await ddClient.docker.cli.exec("logs", [
        "--tail",
        "100",
        "mochoa_oraclexe-docker-extension-desktop-extension-oraclexe-1"
      ]);
      if (xelog.stderr !== "") {
        ddClient.desktopUI.toast.error(xelog.stderr);
      } else {
        setLogs(xelog.stdout);
      }
    };

    let timer = setInterval(() => {
      checkIfOracleXEIsReady();
    }, 1000);

    return () => {
      clearInterval(timer);
    };
  }, []);

  useEffect(() => {
    if (ready) {
      window.location.href = 'http://localhost:9880/em/login?returnUrl=/em/';
    }
  }, [ready]);


  return (
    <Grid container flex={1} direction="column" spacing={4}>
      <Grid item justifyContent="center" textAlign="center" minHeight="80px">
        {!ready && (
          <>
            <LinearProgress />
            <Typography mt={2}>
              Waiting for OracleXE to be ready. It may take several seconds if
              it's the first time.
            </Typography>
            <div style={{ "textAlign": 'left', "height": 400, "width": "100%" }}>
              <ScrollFollow
                startFollowing
                render={({ onScroll, follow, startFollowing, stopFollowing }) => (
                  <LazyLog text={logs} stream follow={follow} />
                )}
              />
            </div>
          </>
        )}
      </Grid>
    </Grid>
  );
}
