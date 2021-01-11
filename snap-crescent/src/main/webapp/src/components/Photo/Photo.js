import React, { useEffect, useState } from 'react'
import { makeStyles } from '@material-ui/core/styles';
import './Photo.scss';
import { SearchTable } from '../SearchTable/SearchTable';
import { search } from '../../services/PhotoService';

const useStyles = makeStyles({
});

export const Photo = () => {

    const classes = useStyles();

    const columns = [
        { field: 'createdDate', headerName: 'Created Date', width: 400 },
        { field: 'device', headerName: 'Device', width: 400 },
        { field: 'location', headerName: 'Location', width: 400 },
      ];
    
    const [rows, setRows] = useState([]);
    const [page, setPage] = useState(0);
    const [totalElements, setTotalElements] = useState(0);

    const getPhotos = () => {
        const searchRequest = {
            page: page
        }
        search(searchRequest)
        .then(res => {
          if (res) {
            setTotalElements(res.totalElements)
          const photos = res.content.map(item => {
                  return {
                      id: {value: item.id, hidden: true},
                      thumbnail: {value: getThumbnailPath(item.thumbnailId), type: 'IMAGE'},
                      createdDate: {value: new Date(item.metadata.createdDate).toLocaleDateString()},
                      device: {value: item.metadata.model ? item.metadata.model : 'Unknown'},
                      location: {value: item.metadata.location ? parseLocation(item.metadata.location) : 'Unknown'}
                  }
              });
              setRows(oldPhotos => [...oldPhotos, ...photos]);
          } 
        });
    }
      useEffect(() => {
        getPhotos();
      }, [page]);

      const getThumbnailPath = (props) => {
        return process.env.REACT_APP_BASE_URL + '/thumbnail/' + props
      }

      const parseLocation = (location) => {
        const city = location.city || location.town;
        const state = location.state;
        const country = location.country;
        
        if(city || state) {
            return city ? city + ', ' + state + ', ' + country : state + ', ' + country;
        } else {
            return country;
        }
      }

    return (
        <div>
                <SearchTable
                  rows={rows}
                  columns={columns}
                  totalElements={totalElements}
                  page={page}
                  setPage={setPage}
                />
        </div>
    )
}