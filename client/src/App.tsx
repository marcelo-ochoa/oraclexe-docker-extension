import { Button, Box, Toolbar } from '@mui/material';
import { useState } from 'react';
import { ReactComponent as StarIcon } from './oraclexe.svg';
import CircularProgress from '@mui/material/CircularProgress';
import SvgIcon from '@mui/icons-material/ScreenshotMonitor';
import Container from '@mui/material/Container';
import AppBar from '@mui/material/AppBar';


export function App() {

  const [backendInfo, setBackendInfo] = useState<string | undefined>();

  let timer = setTimeout(() => checkBackend("http://localhost:9880/em/login?returnUrl=/em/"), 100);

  async function checkBackend(url: string) {
    clearTimeout(timer);
    timer = setTimeout(() => checkBackend(url), 3000);
    let status = await fetch(url)
      .then(response => response.ok);
    if (status) {
      setBackendInfo("ok");
      clearTimeout(timer);
    } else {
      setBackendInfo("error");
    }
  }

  const pages = ['OracleXE','QuickStart', 'FAQ', 'License' ];

  return (
    <AppBar position="static">
    <Container maxWidth="xl">
    <Toolbar>
      <Box sx={{ flexGrow: 1, display: { xs: 'none', md: 'flex' } }}>
        <Button
          key="app"
          onClick={() => backendInfo?.startsWith("ok") ? window.location.href = "http://localhost:9880/em/login?returnUrl=/em/" : null}
          sx={{ my: 1, color: 'white', display: 'block' }}
        >
          {backendInfo?.startsWith("ok") ? <SvgIcon component={StarIcon} inheritViewBox color="success" fontSize="large" sx={{ display: { xs: 'none', md: 'flex' }, mr: 1 }} /> : <CircularProgress />}
        </Button>
        {pages.map((page) => (
              <Button
                key={page}
                href={`${page}.html`}
                target="oraclexe"
                sx={{ my: 1, color: 'white', display: 'block' }}
              >
                {page}
              </Button>
            ))}
          </Box>
        </Toolbar>
      </Container>
    </AppBar>
  );
}
