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
        height: 150,
        width: 150,
        '&:hover': {
            filter: 'brightness(0.8)',
            border: 'solid 2px #15C57E'
        }
    },
    actionBar: {
        height: theme.spacing(6),
        marginBottom: theme.spacing(3),
        background: '#BDBDBD'
    },
    actionBarContainer: {
        color: '#ffffff'
    },
    iconGrid: {
        textAlign: 'right',
        paddingRight: theme.spacing(3)
    }
}));

export const SearchTable = (props) => {
    const classes = useStyles();

    const [view, setView] = useState('COMFY');

    return (
        <div>
            <Paper className={classes.actionBar}>
                <Grid container className={classes.actionBarContainer}>
                    <Grid item sm={6} className='center-content'>
                        <div className="search">
                        <div className="searchIcon">
                            <SearchIcon />
                        </div>
                        <InputBase
                            placeholder="Search…"
                            classes={{
                            root: classes.inputRoot,
                            input: classes.inputInput,
                            }}
                            inputProps={{ 'aria-label': 'search' }} />
                        </div>
                    </Grid>
                    <Grid item sm={6} className={classes.iconGrid}>
                        {   
                            view === 'MODULE' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={()=> setView('COMFY')}>
                                <ViewModuleIcon />
                            </IconButton>
                        }
                        {
                            view === 'COMFY' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={()=> setView('LIST')}>
                                <ViewComfy />
                            </IconButton>
                        }
                        {
                            view === 'LIST' &&
                            <IconButton color="inherit" aria-label="toggle view" onClick={()=> setView('COMFY')}>
                                <ViewList />
                            </IconButton>
                        }
                    </Grid>
                </Grid>
            </Paper>
            {(() => {
                if (view === "LIST") {
                    return (
                        <TableContainer component={Paper}>
                            <Table className={classes.table} aria-label="simple table">
                                <TableHead>
                                    <TableRow>
                                        <TableCell>
                                        </TableCell>
                                        {props.columns.map((column) => (
                                            <TableCell className={classes.head} key={column.field}>
                                                {column.headerName}
                                            </TableCell>
                                        ))}
                                    </TableRow>
                                </TableHead>
                                <TableBody>
                                    {props.rows.map((row) => (
                                        <TableRow key={row.id.value}>
                                            {
                                                Object.entries(row).map(([key, data]) => {
                                                    if (data.hidden) {
                                                        return
                                                    }
                                                    if (data.type === 'IMAGE') {
                                                        return (
                                                            <TableCell><img className={classes.listThumbnail} src={data.value} alt="thumbnail" /></TableCell>
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
                            {props.rows.map((row) => (
                                <GridListTile key={row.id.value} cols={1}>
                                    <img className={classes.gridThumbnail} src={row.thumbnail.value} alt="thumbnail" />
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

        </div>
    );
}