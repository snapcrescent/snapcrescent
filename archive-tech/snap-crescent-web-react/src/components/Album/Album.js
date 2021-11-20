import React, { useState } from 'react';
import { search } from '../../services/AlbumService';
import { SearchTable } from '../SearchTable/SearchTable';

export const  Album = () => {

    const [rows, setRows] = useState([]);
    const [page, setPage] = useState(0);
    const [totalElements, setTotalElements] = useState(0);

    const getAlbums = () => {
        const searchRequest = {
            page: page,
          }
        search(searchRequest)
        .then(res => {
            setTotalElements(res.totalElements)
            const albums = res.content.map(item => {
                return {
                  id: { value: item.id, hidden: true },
                  createdDate: { value: new Date(item.createdDate).toLocaleDateString() },
                  name: { value: item.name },
                }
              });
              setRows(oldAlbums => [...oldAlbums, ...albums]);
        });
    }

    return (
        <>
        <SearchTable
            view='ALBUM'
            rows={rows}
            setRows={setRows}
            totalElements={totalElements}
            page={page}
            setPage={setPage}
            search={getAlbums}
        />
        </>
    )
}