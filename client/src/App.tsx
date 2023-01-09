import { useEffect, useState } from 'react';
import { Box, Grid, LinearProgress, Typography, useTheme } from '@mui/material';
import { createDockerDesktopClient } from '@docker/extension-api-client';


const client = createDockerDesktopClient();

function useDockerDesktopClient() {
  return client;
}

export function App() {
  const [ready, setReady] = useState(false);
  const [unavailable, setUnavailable] = useState(false);
  const ddClient = useDockerDesktopClient();
  const theme = useTheme();

  useEffect(() => {
    let timer: number;

    const start = async () => {
      setReady(() => false);

      let colors = {
        background: theme.palette.background.default,
        foreground: theme.palette.text.primary,
        cursor: theme.palette.docker.grey[800],
        selection: theme.palette.primary.light,
      };
      await ddClient.extension.vm?.service?.post('/start', colors);
    };

    start().then(() => {
      let retries = 10;
      let timer = setInterval(async () => {

        if (retries == 0) {
          clearInterval(timer);
          setUnavailable(true);
        }

        try {
          const result = await ddClient.extension.vm?.service?.get('/ready');

          if (Boolean(result)) {
            setReady(() => true);
            clearInterval(timer);
          }
        } catch (error) {
          console.log('error when checking sqlcl status', error);
          retries--;
        }
      }, 1000);
    }).catch(error => {
      console.log('failed to start sqlcl', error);
      ddClient.desktopUI.toast.error(error);
      setUnavailable(true);
    })

    return () => {
      clearInterval(timer);
    };
  }, [theme]);

  return (
    <>
      {unavailable && (
        <Grid container flex={1} direction="column" padding="16px 32px" height="100%" justifyContent="center" alignItems="center">
          <Grid item>
            SQLcl failed to start, please close the extension and reopen to try again.
          </Grid>
        </Grid>
      )}
      {!ready && (
        <Grid container flex={1} direction="column" padding="16px 32px" height="100%" justifyContent="center" alignItems="center">
          <Grid item>
            <LinearProgress/>
            <Typography mt={2}>
              Waiting for sqlcl to be ready. It may take some seconds if
              it's the first time.
            </Typography>
          </Grid>
        </Grid>
      )}
      {ready && (
        <Box display="flex" flex={1} width="100%" height="100%">
          <iframe src='http://localhost:59890/' width="100%" height="100%" />
        </Box>
      )}
    </>
  );
}
