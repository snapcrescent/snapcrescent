import './App.css';
import { Signup } from './components/Signup/Signup';
import { Signin } from './components/Signin/Signin';
import { Home } from './components/Home/Home';
import { BrowserRouter as Router, Route, Redirect } from 'react-router-dom';
import { Photo } from './components/Photo/Photo';
import { Video } from './components/Video/Video';
import { Favourite } from './components/Favourite/Favourite';
import { Header } from './components/Header/Header';

function App() {

  // ToDO : Need to check User authentication
  const isAuthenticated = localStorage.getItem('authenticated');

  return (
    <div className="App">
      <Router>
        <Route
          exact
          path="/"
          render={() => {
            return (
                isAuthenticated ?
                <Redirect to="/home" /> :
                <Redirect to="/signin" />
            )
          }}
        />
        <Route path='/home' component={Home} />
        <Route path='/signup' component={Signup} />
        <Route path='/signin' component={Signin} />

        {/* <Route path='/photos' exact component={Photo} />
        <Route path='/favourites' exact component={Favourite} />
        <Route path='/videos' exact component={Video} /> */}
      </Router>
    </div>
  );
}

export default App;
