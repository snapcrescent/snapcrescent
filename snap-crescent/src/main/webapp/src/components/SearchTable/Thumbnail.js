import React, { useEffect, useState } from 'react';
import { getById } from '../../services/ThumbnailService';

export const Thumbnail = (props) => {

    const {thumbnailId, className, onClick } = props;
    const [img, setImg] = useState('');
    

    useEffect(() => {
        getById(thumbnailId).then(res => {
            const url = URL.createObjectURL(new Blob([res]));
            setImg(url);
        })
    }, [])

    return(
        <img src={img} className={className} alt='' onClick={onClick} />
    );
}