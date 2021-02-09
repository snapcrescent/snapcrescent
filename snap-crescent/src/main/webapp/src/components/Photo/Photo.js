import React, { useState } from 'react'
import './Photo.scss';
import { SearchTable } from '../SearchTable/SearchTable';
import { search } from '../../services/PhotoService';

const year = new Date().getFullYear();
const years = [{id: '0', value: 'All Years'}];
years.push(...Array.from(new Array(20),( val, index) => ({id: year - index, value: year-index})));
const months = [
    {id: '0', value: 'All Months'},
    {id: '01', value: 'January'},
    {id: '02', value: 'February'},
    {id: '03', value: 'March'},
    {id: '04', value: 'April'},
    {id: '05', value: 'May'},
    {id: '06', value: 'June'},
    {id: '07', value: 'July'},
    {id: '08', value: 'August'},
    {id: '09', value: 'September'},
    {id: '10', value: 'October'},
    {id: '11', value: 'November'},
    {id: '12', value: 'December'},
];

export const Photo = (props) => {

  const searchFields = [
    {key: 'year', options: years, value: '0'},
    {key: 'month', options: months, value: '0'}
  ]
  
  const columns = [
    { field: 'createdDate', headerName: 'Created Date', sortable: true, width: 400 },
    { field: 'device', headerName: 'Device', sortable: true, width: 400 },
    { field: 'location', headerName: 'Location', sortable: false, width: 400 },
  ];

  const [rows, setRows] = useState([]);
  const [page, setPage] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [searchInput, setSearchInput] = useState(null);
  const [searchFormFields, setSearchFormFields] = useState(searchFields);
  const [order, setOrder] = useState('asc');
  const [orderBy, setOrderBy] = useState('createdDate');

  const getPhotos = () => {
    const searchRequest = {
      page: page,
      sort: orderBy,
      sortDirection: order
    }
    if(props.favorite) {
      searchRequest.favorite = props.favorite; 
    }
    if(searchInput) {
      searchRequest.searchInput = searchInput;
    }

    searchFormFields.forEach(searchFormField => {
      if(searchFormField.value !== '0') {
        searchRequest[searchFormField.key] = searchFormField.value;
      }
    });
    search(searchRequest)
      .then(res => {
        if (res) {
          setTotalElements(res.totalElements)
          const photos = res.content.map(item => {
            return {
              id: { value: item.id, hidden: true },
              thumbnail: { value: 'data:image/*;base64,' + item.base64EncodedThumbnail, type: 'IMAGE' },
              createdDate: { value: new Date(item.metadata.createdDate).toLocaleDateString() },
              device: { value: item.metadata.model ? item.metadata.model : 'Unknown' },
              location: { value: item.metadata.location ? parseLocation(item.metadata.location) : 'Unknown' },
              favorite: { value: item.favorite, type: 'ICON'}
            }
          });
          setRows(oldPhotos => [...oldPhotos, ...photos]);
        }
      });
  }

  const parseLocation = (location) => {
    const city = location.city || location.town;
    const state = location.state;
    const country = location.country;

    if (city || state) {
      return city ? city + ', ' + state + ', ' + country : state + ', ' + country;
    } else {
      return country;
    }
  }

  return (
    <div>
      <SearchTable
        rows={rows}
        setRows={setRows}
        columns={columns}
        totalElements={totalElements}
        page={page}
        setPage={setPage}
        setSearchInput={setSearchInput}
        searchFormFields={searchFormFields}
        setSearchFormFields={setSearchFormFields}
        search={getPhotos}
        order={order}
        setOrder={setOrder}
        orderBy={orderBy}
        setOrderBy={setOrderBy}
      />
    </div>
  )
}