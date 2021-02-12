import React from 'react';
import './Home.scss';
import { HashRouter, Route, Redirect } from 'react-router-dom';

import { Sidebar } from '../Sidebar/Sidebar';
import { Photo } from '../Photo/Photo';
import { Video } from '../Video/Video';
import { Loader } from '../Loader/Loader';
import { Album } from '../Album/Album';

export const Home = () => {

    return (
        <HashRouter>
            <div className="root">
                <Loader />
                <Sidebar />
                <div className="m-t-4 w-100">
                    <Route
                        exact
                        path="/home"
                        render={() => {
                            return (
                                <Redirect to="/home/photos" />
                            )
                        }}
                    />
                    <div className="container">
                        <Route path='/home/photos' component={Photo} />
                        <Route path='/home/favorites' render={(props) => <Photo {...props} favorite={true}/>}  />
                        <Route path='/home/albums' component={Album} />
                        <Route path='/home/videos' component={Video} />
                    </div>
                </div>
            </div>
            
        </HashRouter>
    );
}