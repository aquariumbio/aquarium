import Checkbox from '@material-ui/core/Checkbox';
import React, { useState, useEffect } from 'react';
import {
  func, string, object, oneOf,
} from 'prop-types';
import Divider from '@material-ui/core/Divider';
import Typography from '@material-ui/core/Typography';
import { makeStyles } from '@material-ui/core';
import IconButton from '@material-ui/core/IconButton';
import CancelOutlinedIcon from '@material-ui/icons/CancelOutlined';
import jobsAPI from '../../helpers/api/jobsAPI';
import VerticalNavList from './VerticalNavList';
import globalUseSyles from '../../globalUseStyles';
import { useWindowDimensions } from '../../WindowDimensionsProvider';
import { StandardButton } from '../shared/Buttons';
import Main from '../shared/layout/Main';

const useStyles = makeStyles(() => ({
  checkbox: {
    padding: 0,
  },
}));

const ShowByOperation = ({
  category,
  operationType,
  setOperationType,
  setPendingCount,
  setAlertProps,
  actionColumn,
}) => {
  const classes = useStyles();
  const globalClasses = globalUseSyles();
  const { tablet } = useWindowDimensions();

  const [operationTypes, setOperationTypes] = useState();
  const [checked, setChecked] = React.useState([]);

  const init = async (setFirst = true) => {
    const response = await jobsAPI.getCategoryByStatus(category);

    if (!response) {
      return setOperationTypes();
    }

    const { operation_types: opTypes, ...rest } = response;

    if (setFirst) {
      const name = Object.keys(rest)[0];
      const first = {
        name,
        ...rest[name],
      };

      setOperationType(first);
    }
    setOperationTypes(opTypes);

    const count = opTypes.reduce((sum, current) => sum + current.n, 0);
    return setPendingCount(count);
  };

  useEffect(() => {
    init();
  }, [category]);

  const getOperations = async (name) => {
    const { operations } = await jobsAPI.getOperationTypeByCategoryAndStatus(name, category);
    if (!operations) return;

    setOperationType({
      name,
      operations,
    });
  };

  const handleToggle = (value) => () => {
    const currentIndex = checked.indexOf(value);
    const newChecked = [...checked];

    if (currentIndex === -1) {
      newChecked.push(value);
    } else {
      newChecked.splice(currentIndex, 1);
    }

    setChecked(newChecked);
  };

  const createJob = async () => {
    const response = await jobsAPI.create(checked);
    if (!response) {
      return (
        setAlertProps({
          message: 'Error: Job could not be created.',
          severity: 'error',
          open: true,
        })
      );
    }

    // If the operation type still has operations keep the current selected operation
    if (checked.length < operationType.operations.length) {
      init(false);
      getOperations(operationType.name);
    } else {
      init();
    }

    setChecked([]);
    return (
      setAlertProps({
        message: `Job #${response.job.id} is waiting for assignment in Unassigned`,
        severity: 'success',
        open: true,
      })
    );
  };

  const handleRemove = (opId) => (event) => {
    alert('TO DO: Remove operation');
  };

  if (!operationTypes) {
    return <div>{category} has no operations</div>;
  }

  const title = () => (
    <div className={globalClasses.flexWrapper}>
      <StandardButton
        name="create-job"
        text="create job"
        disabled={checked.length < 1}
        icon="attach"
        variant="text"
        handleClick={createJob}
      />
      <Divider />
      <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
        <div className={`${globalClasses.flexCol1}`} />
        <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Plan</Typography></div>
        <div className={`${globalClasses.flexCol4}`}><Typography variant="body2">Input/Output</Typography></div>
        {tablet ? (
          <div className={`${globalClasses.flexCol2}`}><Typography variant="body2">Details</Typography></div>
        ) : (
          <>
            <div className={`${globalClasses.flexCol2}`}><Typography variant="body2">Updated</Typography></div>
            <div className={`${globalClasses.flexCol2}`}><Typography variant="body2">Researcher</Typography></div>
            <div className={`${globalClasses.flexCol1}`}><Typography variant="body2">Op Id</Typography></div>
          </>
        )}
      </div>
    </div>
  );
  const displayInOutData = (operation) => (
    <>
      {!!operation.inputs && operation.inputs.map((input, index) => (
        <div className={`${globalClasses.flex} ${globalClasses.flexRowNested}`}>
          <div className={globalClasses.flexCol1}>
            <Typography variant="body2" noWrap>{index === 0 ? 'in:' : ''}</Typography>
          </div>
          <div className={globalClasses.flexCol2}>
            <Typography variant="body2" noWrap>{input.name}</Typography>
          </div>
          {input.sample_id && input.sample_name ? (
            <div className={globalClasses.flexCol4}>
              <Typography variant="body2" noWrap>{input.sample_id}: {input.sample_name}</Typography>
            </div>
          ) : <div className={globalClasses.flexCol4} />}
        </div>
      ))}

      {!!operation.outputs && operation.outputs.map((output, index) => (
        <div className={`${globalClasses.flex}`}>
          <div className={globalClasses.flexCol1}>
            <Typography variant="body2">{index === 0 ? 'out:' : ''}</Typography>
          </div>
          <div className={globalClasses.flexCol2}>
            <Typography variant="body2" noWrap>{output.name}</Typography>
          </div>
          {output.sample_id && output.sample_name ? (
            <div className={globalClasses.flexCol4}>
              <Typography variant="body2" noWrap>{output.sample_id}: {output.sample_name}</Typography>
            </div>
          ) : <div className={globalClasses.flexCol4} />}
        </div>
      ))}

      {!!operation.data_associations && operation.data_associations.map((da) => {
        const data = JSON.parse(da.object);
        const key = Object.keys(data)[0];
        const value = data[key];
        // if no associated text skip row
        if (value === '') {
          return false;
        }
        return (
          <div className={`${globalClasses.flex}`}>
            <div className={globalClasses.flexCol1} />
            <div className={globalClasses.flexCol2}>
              <Typography variant="body2" noWrap>{key.replace('_', ' ')}:</Typography>
            </div>
            <div className={globalClasses.flexCol4}>
              <Typography variant="body2" noWrap>{value}</Typography>
            </div>
          </div>
        );
      })}
    </>
  );

  const rows = () => (
    operationType.operations.map((operation) => (
      <div className={globalClasses.flexWrapper} key={operation.id}>
        <div className={`${globalClasses.flex} ${globalClasses.flexRow} ${checked.includes(operation.id) && globalClasses.hightlight}`} key={`op_${operation.id}`}>
          <div className={`${globalClasses.flexCol1}`}>
            {actionColumn === 'create' && (
              <Checkbox
                color="primary"
                inputProps={{ 'aria-label': 'operation-checkbox' }}
                edge="end"
                checked={checked.indexOf(operation.id) !== -1}
                onChange={handleToggle(operation.id)}
                tabIndex={-1}
                disableRipple
                className={classes.checkbox}
              />
            )}
            {actionColumn === 'remove' && (
              <IconButton aria-label="cancel job" onClick={() => { handleRemove(operation.id); }}>
                <CancelOutlinedIcon htmlColor="#FF0000" />
              </IconButton>
            )}

          </div>
          <div className={`${globalClasses.flexCol1}`}>
            <Typography variant="body2" noWrap>{operation.plan_id}</Typography>
          </div>
          <div className={`${globalClasses.flexCol4}`}>
            {displayInOutData(operation)}
          </div>
          {tablet ? (
            <div className={`${globalClasses.flexCol2}`}>
              <Typography variant="body2" noWrap>Updated: {operation.updated_at.substring(0, 16).replace('T', ' ')}</Typography>
              <Typography variant="body2" noWrap>Researcher: {operation.name}</Typography>
              <Typography variant="body2" noWrap>Op Id: {operation.id}</Typography>
            </div>
          ) : (
            <>
              <div className={`${globalClasses.flexCol2}`}>
                <Typography variant="body2" noWrap>{operation.updated_at.substring(0, 16).replace('T', ' ')}</Typography>
              </div>
              <div className={`${globalClasses.flexCol2}`}>
                <Typography variant="body2" noWrap>{operation.name}</Typography>
              </div>
              <div className={`${globalClasses.flexCol1}`}>
                <Typography variant="body2" noWrap>{operation.id}</Typography>
              </div>
            </>
          )}
        </div>
      </div>
    ))
  );

  return (
    <>
      {actionColumn === 'create' && ( // Full page view w/ sidebar
        <>
          <VerticalNavList
            name="operation-types"
            list={operationTypes}
            value={operationType}
            getOperations={getOperations}
          />
          <Main numOfSections={3} title={title()}>
            {rows()}
          </Main>
        </>
      )}

      {actionColumn === 'remove' && ( // Accordion view
        <Main numOfSections={1} title={title()}>
          {rows()}
        </Main>
      )}
    </>
  );
};

ShowByOperation.propTypes = {
  category: string.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  operationType: object.isRequired,
  setOperationType: func.isRequired,
  setPendingCount: func.isRequired,
  setAlertProps: func.isRequired,
  actionColumn: oneOf(['remove', 'create']).isRequired,
};

export default ShowByOperation;
