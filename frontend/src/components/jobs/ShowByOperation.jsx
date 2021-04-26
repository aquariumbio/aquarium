import React, { useState, useEffect } from 'react';
import { func, string } from 'prop-types';
import { makeStyles } from '@material-ui/core';
import Divider from '@material-ui/core/Divider';
import jobsAPI from '../../helpers/api/jobsAPI';
import FlexTable from '../shared/felx/FlexTable';
import FlexColumn from '../shared/felx/FlexColumn';
import FlexTitle from '../shared/felx/FlexTitle';
import FlexRow from '../shared/felx/FlexRow';
import VerticalNavList from './VerticalNavList';

const useStyles = makeStyles((theme) => ({
  root: {
    height: 'calc(100% - 64px)',
    display: 'flex',
  },

  inventory: {
    fontSize: '0.875rem',
    marginBottom: theme.spacing(2),
  },

  /* Use to scale and hide columns in the title row */
  flexColAutoHidden: {
    width: 'auto',
    marginRight: '8px',
    paddingLeft: '8px',
    minWidth: '0',
    visibility: 'hidden',
  },

  show: {
    display: 'block',
  },

  hide: {
    display: 'none',
  },

  pointer: {
    cursor: 'pointer',
  },
}));

// eslint-disable-next-line no-unused-vars
const ShowByOperation = ({
  category,
  operationType,
  setOperationType,
  setIsLoading,
  setAlertProps,
}) => {
  const classes = useStyles();

  const [operationTypes, setOperationTypes] = useState();
  const [operations, setOperations] = useState();

  const init = async () => {
    const response = await jobsAPI.getCategoryByStatus(category);

    if (!response) return;

    const { operation_types: opTypes, ...rest } = response;

    const name = Object.keys(rest)[0];
    setOperationType(name);
    setOperations(rest[name].operations);
    setOperationTypes(opTypes);
  };

  useEffect(() => {
    init();
  }, [category]);

  const getOperations = async () => {
    const response = await jobsAPI.getOperationTypeByCategoryAndStatus(operationType, category);
    if (!response) return;
    setOperations(response.operations);
  };

  useEffect(() => {
    getOperations();
  }, [operationType]);

  if (!operationTypes) {
    return <div>{category} has no operations</div>;
  }

  const rows = () => {
    if (!operations) {
      return <div> No operations</div>;
    }

    return (
      operations.map((operation) => (
        <FlexRow key={`job_${operation.id}`}>
          <FlexColumn flex="flexCol1">{operation.plan_id}</FlexColumn>
          <FlexColumn flex="flexCol2">{operation.options}</FlexColumn>
          <FlexColumn flex="flexCol1">{operation.updated_at.substring(0, 16).replace('T', ' ')}</FlexColumn>
          <FlexColumn flex="flexCol1">{operation.name}</FlexColumn>
          <FlexColumn flex="flexCol1">{operation.id}</FlexColumn>
        </FlexRow>
      ))
    );
  };

  return (
    <div id="show-by-operation" className={classes.root}>
      <VerticalNavList
        name="operation-types"
        list={operationTypes}
        value={operationType}
        setOperationType={setOperationType}
      />
      <div style={{ width: '100%', marginLeft: '20px' }}>
        <Divider style={{ marginTop: '0' }} />
        <div>
          <FlexTable>
            <FlexTitle>
              <FlexColumn flex="flexCol1">Plan</FlexColumn>
              <FlexColumn flex="flexCol2">Input/Output</FlexColumn>
              <FlexColumn flex="flexCol1">Updated</FlexColumn>
              <FlexColumn flex="flexCol1">Researcher</FlexColumn>
              <FlexColumn flex="flexCol1">Op Id</FlexColumn>
            </FlexTitle>
            {rows()}
          </FlexTable>
        </div>
      </div>
    </div>

  );
};

ShowByOperation.propTypes = {
  category: string.isRequired,
  operationType: string.isRequired,
  setOperationType: func.isRequired,
  setIsLoading: func.isRequired,
  setAlertProps: func.isRequired,
};

export default ShowByOperation;
