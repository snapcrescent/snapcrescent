import React from 'react';
import { BrowserRouter as Router, Route } from 'react-router-dom';

import { Header } from '../Header/Header';
import { Footer } from '../Footer/Footer';
import { Photo } from '../Photo/Photo';
import { Video } from '../Video/Video';
import { Favourite } from '../Favourite/Favourite';

export const Home = () => {

    return (
        <Router>
            <Header />
            <Route path='/photos' component={Photo} />
            <Route path='/favourites' component={Favourite} />
            <Route path='/videos' component={Video} />
            <Footer />
        </Router>
    );
}