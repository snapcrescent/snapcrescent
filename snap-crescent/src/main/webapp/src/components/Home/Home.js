import React from 'react';
import './Home.scss';
import { BrowserRouter as Router, Route, Redirect } from 'react-router-dom';

import { Header } from '../Header/Header';
import { Sidebar } from '../Sidebar/Sidebar';
import { Photo } from '../Photo/Photo';
import { Video } from '../Video/Video';
import { Favorite } from '../Favorite/Favorite';

export const Home = () => {

    return (
        <Router>
            {/* <Header /> */}
            <div className="root">
                <Sidebar />
                <div className="m-t-4">
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
                    <Route path='/home/favorites' component={Favorite} />
                    <Route path='/home/videos' component={Video} />
                </div>
            </div>
            
        </Router>
    );
}