import React, { useEffect, useState } from 'react'
import { makeStyles } from '@material-ui/core/styles';
import './Photo.scss';
import { SearchTable } from '../SearchTable/SearchTable';
import { search } from '../../services/PhotoService';
import InfiniteScroll from 'react-infinite-scroll-component';

const useStyles = makeStyles({
    scrollContainer: {
        overflow: 'hidden !important'
    }
});

export const Photo = () => {

    const classes = useStyles();

    const columns = [
        { field: 'createdDate', headerName: 'Created Date', width: 400 },
        { field: 'device', headerName: 'Device', width: 400 },
        { field: 'size', headerName: 'Size', width: 400 },
      ];
    
    const [rows, setRows] = useState([]);
    const [pageSize, setPageSize] = useState(50);
    const [totalElements, setTotalElements] = useState(0);

    const getPhotos = () => {
        const searchRequest = {
            size: pageSize
        }
        search(searchRequest)
        .then(res => {
          if (res) {
            setTotalElements(res.totalElements)
          const photos = res.content.map(item => {
                  return {
                      id: item.id,
                      createdDate: item.metadata.createdDate,
                      device: item.metadata.model ? item.metadata.model : 'Unknown',
                      size: item.metadata.size,
                      thumbnail: getThumbnailPath(item.thumbnailId)
                  }
              });
              setRows(photos);
          } 
        });
    }
      useEffect(() => {
        getPhotos();
      }, [pageSize]);

      const getThumbnailPath = (props) => {
        return process.env.REACT_APP_BASE_URL + '/thumbnail/' + props
      }

    return (
        <div>
            <InfiniteScroll
                dataLength={rows.length}
                next={()=>{setPageSize(pageSize+10)}}
                hasMore={totalElements > rows.length}
                className={classes.scrollContainer}
            >
                <SearchTable rows={rows} columns={columns} view="GRID"/>
            </InfiniteScroll>
        </div>
    )
}