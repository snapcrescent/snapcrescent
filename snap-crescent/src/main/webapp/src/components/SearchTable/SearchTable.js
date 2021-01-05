import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import GridList from '@material-ui/core/GridList';
import GridListTile from '@material-ui/core/GridListTile';


const useStyles = makeStyles({
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
    }
});

export const SearchTable = (props) => {
    const classes = useStyles();

    return (
        <div>
            {(() => {
                    if (props.view === "LIST") {
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
                                            <TableRow key={row.id}>
                                                <TableCell><img className={classes.listThumbnail} src={row.thumbnail} alt="thumbnail" /></TableCell>
                                                <TableCell>{row.createdDate}</TableCell>
                                                <TableCell>{row.device}</TableCell>
                                                <TableCell>{row.size}</TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            </TableContainer>
                        )
                    } else if (props.view === "GRID") {
                        return (
                            <GridList cellHeight={'auto'} className={classes.gridList} cols={0} spacing={10}>
                            {props.rows.map((row) => (
                                <GridListTile key={row.thumbnail} cols={1}>
                                <img className={classes.gridThumbnail} src={row.thumbnail} alt="thumbnail" />
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