import React from 'react';
import './Home.scss';
import { HashRouter, Route, Redirect } from 'react-router-dom';

import { Sidebar } from '../Sidebar/Sidebar';
import { Photo } from '../Photo/Photo';
import { Video } from '../Video/Video';
import { Favorite } from '../Favorite/Favorite';
import { Loader } from '../Loader/Loader';

export const Home = () => {

    return (
        <HashRouter>
            {/* <Header /> */}
            <div className="root">
                <Loader />
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
            
        </HashRouter>
    );
}