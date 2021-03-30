import React from 'react';
import Typography from '@material-ui/core/Typography';
import utils from '../../helpers/utils';

export const greetings = {
  French: 'Bonjour',
  Spanish: 'Hola',
  Russian: 'Privet',
  Chinese: 'Nǐ hǎo',
  Italian: 'Ciao',
  Japanese: 'Konnichiwa',
  German: 'Guten Tag',
  Portuguese: 'Olá',
  Korean: 'Anyoung',
  Arabic: 'Ahlan',
  Danish: 'Hej',
  Swahili: 'Habari',
  Dutch: 'Hoi',
  Greek: 'Yassou',
  Polish: 'Cześć',
  Indonesian: 'Halo',
  Hindi: 'Namaste',
  Turkish: 'Selam',
  Hebrew: 'Shalom',
  Swedish: 'Tjena',
  Norwegian: 'God dag',
};

const UserGreeting = () => {
  const userName = (localStorage.getItem('user') && JSON.parse(localStorage.getItem('user')).name) || 'User';
  const greeting = utils.randObjVal(greetings);

  return <Typography style={{ fontSize: '16px' }}>{greeting} {userName}!</Typography>;
};

export default UserGreeting;
