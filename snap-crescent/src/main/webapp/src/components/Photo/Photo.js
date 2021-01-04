import React, { useEffect, useState } from 'react'
import './Photo.scss';
import { SearchTable } from '../SearchTable/SearchTable';
import { search } from '../../services/PhotoService';

export const Photo = () => {

    const columns = [
        { field: 'createdDate', headerName: 'Created Date', width: 400 },
        { field: 'device', headerName: 'Device', width: 400 },
        { field: 'size', headerName: 'Size', width: 400 },
      ];
    
    const [rows, setRows] = useState([]);

      useEffect(() => {
        search()
          .then(res => {
            if (res) {
            const photos = res.map(item => {
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
      }, []);

      const getThumbnailPath = (props) => {
        return process.env.REACT_APP_BASE_URL + '/thumbnail/' + props
      }

    return (
        <div>
            <SearchTable rows={rows} columns={columns} />
        </div>
    )
}