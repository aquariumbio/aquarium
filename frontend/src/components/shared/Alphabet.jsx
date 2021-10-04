import React, { useEffect, useState } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import PropTypes from 'prop-types';

import Button from '@material-ui/core/Button';

import { LinkButton } from './Buttons';
import globalUseSyles from '../../globalUseStyles';

const useStyles = makeStyles((theme) => ({
  letter: {
    color: theme.palette.primary.main,
  },
}));

const Alphabet = ({ fetchLetter, fetchAll }) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();

  return (
    <div className={globalClasses.wrapper}>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchAll()}>All</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('A')}>A</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('B')}>B</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('C')}>C</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('D')}>D</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('E')}>E</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('F')}>F</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('G')}>G</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('H')}>H</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('I')}>I</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('J')}>J</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('K')}>K</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('L')}>L</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('M')}>M</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('N')}>N</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('O')}>O</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('P')}>P</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Q')}>Q</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('R')}>R</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('S')}>S</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('T')}>T</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('U')}>U</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('V')}>V</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('W')}>W</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('X')}>X</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Y')}>Y</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('Z')}>Z</Button>
      <Button className={classes.letter} variant="outlined" onClick={() => fetchLetter('*')}>*</Button>
    </div>
  );
};

Alphabet.propTypes = {
  fetchLetter: PropTypes.func.isRequired,
  fetchAll: PropTypes.func.isRequired,
};

export default Alphabet;
