import React, { useEffect, useState } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import Grid from '@material-ui/core/Grid';
import GridList from '@material-ui/core/GridList';
import GridListTile from '@material-ui/core/GridListTile';
import GridListTileBar from '@material-ui/core/GridListTileBar';
import InputBase from '@material-ui/core/InputBase';
import SearchIcon from '@material-ui/icons/Search';
import IconButton from '@material-ui/core/IconButton';
import ViewModuleIcon from '@material-ui/icons/ViewModule';
import ViewComfy from '@material-ui/icons/ViewComfy';
import ViewList from '@material-ui/icons/ViewList';
import { PhotoSlide } from '../PhotoSlide/PhotoSlide';
import InfiniteScroll from 'react-infinite-scroll-component';
import FavoriteBorderIcon from '@material-ui/icons/FavoriteBorder';
import FavoriteIcon from '@material-ui/icons/Favorite';
import { like } from '../../services/PhotoService';
import Accordion from '@material-ui/core/Accordion';
import AccordionDetails from '@material-ui/core/AccordionDetails';
import AccordionSummary from '@material-ui/core/AccordionSummary';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import MenuItem from '@material-ui/core/MenuItem';
import FormControl from '@material-ui/core/FormControl';
import Select from '@material-ui/core/Select';
import TableSortLabel from '@material-ui/core/TableSortLabel';
import PhotoCameraIcon from '@material-ui/icons/PhotoCamera';
import DateRangeIcon from '@material-ui/icons/DateRange';

import './SearchTable.scss';

const useStyles = makeStyles((theme) => ({
    table: {
        minWidth: 650,
    },
    head: {
        fontWeight: 600
    },
    listThumbnail: {
        height: 75,
        width: 75,
        '&:hover': {
            filter: 'brightness(0.8)',
            border: 'solid 2px #15C57E'
        }
    },
    gridThumbnail: {
        height: 142,
        width: 142,
        '&:hover': {
            filter: 'brightness(0.8)',
            border: 'solid 2px #15C57E'
        }
    },
    moduleThumbnail: {
        height: 270,
        width: 270,
        '&:hover': {
            filter: 'brightness(0.8)',
            border: 'solid 2px #15C57E'
        }
    },
    accordion: {
        marginBottom: theme.spacing(2),
    },
    accordionSummary: {
        height: theme.spacing(6),
        background: '#5E5E5E',
        color: '#ffffff'
    },
    accordionDetails: {
        background: '#767676'
    },
    formControl: {
        margin: theme.spacing(1),
        minWidth: 120,
    },
    inputSelect: {
        width: theme.spacing(25),
        background: '#ffffff'
    },
    iconGrid: {
        textAlign: 'right',
        paddingRight: theme.spacing(3)
    },
    scrollContainer: {
        overflow: 'hidden !important'
    },
    inputRoot: {
        width: '80%'
    },
    gridFavoriteButton: {
        position: 'absolute',
        top: theme.spacing(13),
        left: theme.spacing(-1),
        zIndex: 1,
        color: '#ffffff'
    },
    moduleFavoriteButton: {
        color: '#ffffff'
    },
    hidden: {
        border: 0,
        clip: 'rect(0 0 0 0)',
        height: 1,
        margin: -1,
        overflow: 'hidden',
        padding: 0,
        position: 'absolute',
        top: 20,
        width: 1,
    }
}));

const Favorite = (props) => {
    const { row, className, toggleFavorite } = props;
    const [favorite, setFavorite] = useState(row.favorite.value);
    return (
        <>
            {
                <IconButton color="inherit" className={className} onClick={() => {toggleFavorite(); setFavorite(!favorite)}}>
                    { favorite &&
                        <FavoriteIcon />
                    }
                    { !favorite &&
                        <FavoriteBorderIcon />
                    }
                </IconButton>
            }
        </>
    )
}
export const SearchTable = (props) => {
    const classes = useStyles();
    const { rows, columns, totalElements, page, setPage, setRows, searchInput, setSearchInput, searchFormFields, setSearchFormFields, search, order, setOrder, orderBy, setOrderBy } = props;
    const [view, setView] = useState('COMFY');

    const [openPhotoSlideDialog, setOpenPhotoSlideDialog] = useState(false);
    const [selectedId, setSelectedId] = useState(null);

    const handleThumbnailClick = (id) => {
        setOpenPhotoSlideDialog(true);
        setSelectedId(id);
    }

    const toggleFavorite = (row) => {
        like(row.id.value).then(res => {
            rows.forEach(item => {
                if(item.id.value === row.id.value) {
                    item.favorite.value = !item.favorite.value;
                }
            })
            setRows(rows);
        });
    }

    const handleSearchInput = (event) => {
        if(event.key === 'Enter') {
            setRows([]);
            setSearchInput(event.target.value);
        }
    }

    const handleSearchFormChange = (key, value) => {

        if(key === 'sort') {    
            handleSort(value);
        } else {
            searchFormFields.forEach(searchFormField => {
                if(searchFormField.key === key) {
                    searchFormField.value = value;
                }
            });
            setSearchFormFields(searchFormFields);
            setRows([]);
            search();
        }
    }

    const createSortHandler = (property) => (event) => {
        handleSort(property);
    };

    const handleSort = (property) => {

        searchFormFields.filter(item => item.key === 'sort').forEach(searchFormField => {
            searchFormField.value = property;
        });
        setSearchFormFields(searchFormFields);
        setRows([]);
        const isAsc = orderBy === property && order === 'asc';
        setOrder(isAsc ? 'desc' : 'asc');
        setOrderBy(property);
    }

    useEffect(() => {
        if(localStorage.getItem('view')) {
            setView(localStorage.getItem('view'));
        } else {
            localStorage.setItem('view', view);
        }
        search();
    }, [page, searchInput, order, orderBy]);

    const switchView = (event, props) => {
        event.stopPropagation();
        setView(props);
        localStorage.setItem('view', props);
    }
    return (
        <div>
            <Accordion className={classes.accordion}>
            <AccordionSummary className={classes.accordionSummary} expandIcon={<ExpandMoreIcon />}>
                <Grid container>
                    <Grid item sm={4} className='center-content'>
                        <div className="search">
                            <div className="searchIcon">
                                <SearchIcon />
                            </div>
                            <InputBase
                                placeholder="Search…"
                                classes={{
                                    root: classes.inputRoot,
                                    input: classes.inputInput
                                }}
                                inputProps={{ 'aria-label': 'search' }}
                                onClick={(event) => event.stopPropagation()}
                                onFocus={(event) => event.stopPropagation()}
                                onKeyUp={handleSearchInput} />
                        </div>
                    </Grid>
                    <Grid item sm={8} className={classes.iconGrid}>
                        {
                            view === 'MODULE' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={(event) => {switchView(event, 'COMFY')}}>
                                <ViewModuleIcon />
                            </IconButton>
                        }
                        {
                            view === 'COMFY' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={(event) => {switchView(event, 'LIST')}}>
                                <ViewComfy />
                            </IconButton>
                        }
                        {
                            view === 'LIST' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={(event) => {switchView(event, 'MODULE')}}>
                                <ViewList />
                            </IconButton>
                        }
                    </Grid>
                </Grid>
            </AccordionSummary>
            <AccordionDetails className={classes.accordionDetails}>

                {
                    searchFormFields.map(searchFormField => (
                        <FormControl variant="outlined" className={classes.formControl}>
                            <Select
                                className={classes.inputSelect}
                                value={searchFormField.value}
                                name={searchFormField.key}
                                id={searchFormField.key}
                            >
                            {
                                searchFormField.options.map(option => (
                                    <MenuItem value={option.id} onClick={() => handleSearchFormChange(searchFormField.key,option.id)} >{option.value}</MenuItem>        
                                ))
                            }
                            </Select>
                        </FormControl>
                    ))
                }
            </AccordionDetails>
            </Accordion>
            <InfiniteScroll
                dataLength={rows.length}
                next={() => { setPage(page + 1) }}
                hasMore={totalElements > rows.length}
                className={classes.scrollContainer}
            >
                {(() => {
                    if(rows.length === 0) {
                        return (
                            <strong>
                                No Result Found
                            </strong>
                        )
                    }
                    if (view === "LIST") {
                        return (
                            <TableContainer component={Paper}>
                                <Table className={classes.table} aria-label="simple table">
                                    <TableHead>
                                        <TableRow>
                                            <TableCell />
                                            {columns.map((column) => (
                                                <TableCell className={classes.head} key={column.field} sortDirection={orderBy === column.field ? order : false}>
                                                    { column.sortable &&
                                                    <TableSortLabel
                                                        active={orderBy === column.field}
                                                        direction={orderBy === column.field ? order : 'asc'}
                                                        onClick={createSortHandler(column.field)}
                                                        >
                                                        {column.headerName}
                                                        {orderBy === column.field ? (
                                                            <span className={classes.hidden}>
                                                            {order === 'desc' ? 'sorted descending' : 'sorted ascending'}
                                                            </span>
                                                        ) : null}
                                                    </TableSortLabel>
                                                    }
                                                    {
                                                        !column.sortable &&
                                                        <span>
                                                            {column.headerName}
                                                        </span>
                                                    }
                                                </TableCell>
                                            ))}
                                            <TableCell />
                                        </TableRow>
                                    </TableHead>
                                    <TableBody>
                                        {rows.map((row) => (
                                            <TableRow key={row.id.value}>
                                                {
                                                    Object.values(row).map((data) => {
                                                        if (data.hidden) {
                                                            return
                                                        }
                                                        if (data.type === 'IMAGE') {
                                                            return (
                                                                <TableCell>
                                                                    <img src={data.value}
                                                                        className={classes.listThumbnail}
                                                                        alt=''
                                                                        onClick={() => { handleThumbnailClick(row.id.value) }}
                                                                    />
                                                                </TableCell>
                                                            )
                                                        } if (data.type === 'ICON') {
                                                            return (
                                                                <TableCell>
                                                                    <Favorite row={row} toggleFavorite={() => toggleFavorite(row)} />
                                                                </TableCell>
                                                            )
                                                        } 
                                                        else {
                                                            return (
                                                                <TableCell>{data.value}</TableCell>
                                                            )
                                                        }
                                                    })
                                                }
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            </TableContainer>
                        )
                    } else if (view === "COMFY") {
                        return (
                            <GridList cellHeight={'auto'} cols={0} spacing={10}>
                                {rows.map((row) => (
                                    <GridListTile key={row.id.value} cols={1}>
                                        <Favorite row={row} className={classes.gridFavoriteButton} toggleFavorite={() => toggleFavorite(row)} />
                                        <img src={row.thumbnail.value}
                                            className={classes.gridThumbnail}
                                            alt=''
                                            onClick={() => handleThumbnailClick(row.id.value)}
                                        />
                                    </GridListTile>
                                ))}
                            </GridList>
                        )
                    } else {
                        return (
                            <GridList cellHeight={'auto'} cols={0} spacing={10}>
                                {rows.map((row) => (
                                    <GridListTile key={row.id.value} cols={1}>
                                        <img src={row.thumbnail.value}
                                            className={classes.moduleThumbnail}
                                            alt=''
                                            onClick={() => handleThumbnailClick(row.id.value)}
                                        />
                                        <GridListTileBar
                                            subtitle={
                                                <span className="text-left">
                                                    <div><PhotoCameraIcon className="icon-16 mr-1" />{row.device.value}</div>
                                                    <div><DateRangeIcon className="icon-16 mr-1" />{row.createdDate.value}</div>
                                                </span>
                                            }
                                            actionIcon={
                                                <Favorite row={row} className={classes.moduleFavoriteButton} toggleFavorite={() => toggleFavorite(row)} />
                                            }
                                        />
                                    </GridListTile>
                                ))}
                            </GridList>
                        )
                    }
                })()}
            </InfiniteScroll>

            <PhotoSlide
                openDialog={openPhotoSlideDialog}
                setOpenDialog={setOpenPhotoSlideDialog}
                fullScreen={true}
                selectedId={selectedId}
                setSelectedId={setSelectedId}
                photos={rows}
                totalElements={totalElements}
                page={page}
                setPage={setPage}
            ></PhotoSlide>
        </div>
    );
}