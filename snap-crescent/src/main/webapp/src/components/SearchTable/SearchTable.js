import React, { useState } from 'react';
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
import InputBase from '@material-ui/core/InputBase';
import SearchIcon from '@material-ui/icons/Search';
import IconButton from '@material-ui/core/IconButton';
import ViewModuleIcon from '@material-ui/icons/ViewModule';
import ViewComfy from '@material-ui/icons/ViewComfy';
import ViewList from '@material-ui/icons/ViewList';
import { PhotoSlide } from '../PhotoSlide/PhotoSlide';
import InfiniteScroll from 'react-infinite-scroll-component';
import { getById } from '../../services/ThumbnailService';
import { Thumbnail } from './Thumbnail';

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
    actionBar: {
        height: theme.spacing(6),
        marginBottom: theme.spacing(2),
        background: '#5CA591'
    },
    actionBarContainer: {
        color: '#ffffff'
    },
    iconGrid: {
        textAlign: 'right',
        paddingRight: theme.spacing(3)
    },
    scrollContainer: {
        overflow: 'hidden !important'
    },
    inputRoot: {
        left: theme.spacing(6)
    }
}));

export const SearchTable = (props) => {
    const classes = useStyles();
    const { rows, columns, totalElements, page, setPage } = props;
    const [view, setView] = useState('LIST');

    const [openPhotoSlideDialog, setOpenPhotoSlideDialog] = useState(false);
    const [selectedId, setSelectedId] = useState(null);

    const handleThumbnailClick = (id) => {
        setOpenPhotoSlideDialog(true);
        setSelectedId(id);
    }

    return (
        <div>
            <Paper className={classes.actionBar}>
                <Grid container className={classes.actionBarContainer}>
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
                                inputProps={{ 'aria-label': 'search' }} />
                        </div>
                    </Grid>
                    <Grid item sm={8} className={classes.iconGrid}>
                        {
                            view === 'MODULE' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={() => setView('COMFY')}>
                                <ViewModuleIcon />
                            </IconButton>
                        }
                        {
                            view === 'COMFY' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={() => setView('LIST')}>
                                <ViewComfy />
                            </IconButton>
                        }
                        {
                            view === 'LIST' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={() => setView('COMFY')}>
                                <ViewList />
                            </IconButton>
                        }
                    </Grid>
                </Grid>
            </Paper>
            <InfiniteScroll
                dataLength={rows.length}
                next={() => { setPage(page + 1) }}
                hasMore={totalElements > rows.length}
                className={classes.scrollContainer}
            >
                {(() => {
                    if (view === "LIST") {
                        return (
                            <TableContainer component={Paper}>
                                <Table className={classes.table} aria-label="simple table">
                                    <TableHead>
                                        <TableRow>
                                            <TableCell>
                                            </TableCell>
                                            {columns.map((column) => (
                                                <TableCell className={classes.head} key={column.field}>
                                                    {column.headerName}
                                                </TableCell>
                                            ))}
                                        </TableRow>
                                    </TableHead>
                                    <TableBody>
                                        {rows.map((row) => (
                                            <TableRow key={row.id.value}>
                                                {
                                                    Object.entries(row).map(([key, data]) => {
                                                        if (data.hidden) {
                                                            return
                                                        }
                                                        if (data.type === 'IMAGE') {
                                                            return (
                                                                <TableCell>
                                                                    <img src={data.value}
                                                                        className={classes.listThumbnail}
                                                                        alt=''
                                                                        onClick={() => { handleThumbnailClick(row.id.value) }} />
                                                                </TableCell>
                                                            )
                                                        } else {
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
                                        <Thumbnail
                                            thumbnailId={row.thumbnail.value}
                                            className={classes.gridThumbnail}
                                            onClick={() => handleThumbnailClick(row.thumbnail.value)} />
                                    </GridListTile>
                                ))}
                            </GridList>
                        )
                    } else {
                        return (
                            <div>

                            </div>
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