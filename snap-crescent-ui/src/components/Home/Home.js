import React from 'react';
import { BrowserRouter as Router, Route, Redirect } from 'react-router-dom';

import { Header } from '../Header/Header';
import { Photo } from '../Photo/Photo';
import { Video } from '../Video/Video';
import { Favourite } from '../Favourite/Favourite';

export const Home = () => {

    return (
        <Router>
            <Header />
            <Route
                exact
                path="/home"
                render={() => {
                    return (
                        <Redirect to="/home/photos" />
                    )
                }}
            />
            <Route path='/home/photos' component={Photo} />
            <Route path='/home/favourites'component={Favourite} />
            <Route path='/home/videos' component={Video} />
            
        </Router>
    );
}