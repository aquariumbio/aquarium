import Checkbox from '@material-ui/core/Checkbox';
import React, { useState, useEffect } from 'react';
import { func, string, object } from 'prop-types';
import Divider from '@material-ui/core/Divider';
import Typography from '@material-ui/core/Typography';
import jobsAPI from '../../helpers/api/jobsAPI';
import VerticalNavList from './VerticalNavList';
import globalUseSyles from '../../globalUseStyles';
import { useWindowDimensions } from '../../WindowDimensionsProvider';
import { StandardButton } from '../shared/Buttons';
import Main from '../shared/layout/Main';

const ShowByOperation = ({
  category,
  operationType,
  setOperationType,
  setPendingCount,
  setAlertProps,
}) => {
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
        dense
        variant="text"
        handleClick={createJob}
      />
      <Divider />
      <div className={`${globalClasses.flex} ${globalClasses.flexTitle}`}>
        <div className={`${globalClasses.flexCol1}`} />
        <div className={`${globalClasses.flexCol1}`}>Plan</div>
        <div className={`${globalClasses.flexCol4}`}>Input/Output</div>
        {tablet ? (
          <div className={`${globalClasses.flexCol2}`}>Details</div>
        ) : (
          <>
            <div className={`${globalClasses.flexCol2}`}>Updated</div>
            <div className={`${globalClasses.flexCol2}`}>Researcher</div>
            <div className={`${globalClasses.flexCol1}`}>Op Id</div>
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
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{index === 0 ? 'in:' : ''}</Typography>
          </div>
          <div className={globalClasses.flexCol2}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{input.name}</Typography>
          </div>
          {input.sample_id && input.sample_name ? (
            <div className={globalClasses.flexCol4}>
              <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{input.sample_id}: {input.sample_name}</Typography>
            </div>
          ) : <div className={globalClasses.flexCol4} />}
        </div>
      ))}

      {!!operation.outputs && operation.outputs.map((output, index) => (
        <div className={`${globalClasses.flex} ${globalClasses.flexRowNested}`}>
          <div className={globalClasses.flexCol1}>
            <Typography variant={tablet ? 'body2' : 'body1'}>{index === 0 ? 'out:' : ''}</Typography>
          </div>
          <div className={globalClasses.flexCol2}>
            <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{output.name}</Typography>
          </div>
          {output.sample_id && output.sample_name ? (
            <div className={globalClasses.flexCol4}>
              <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{output.sample_id}: {output.sample_name}</Typography>
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
          <div className={`${globalClasses.flex} ${globalClasses.flexRowNested}`}>
            <div className={globalClasses.flexCol1} />
            <div className={globalClasses.flexCol2}>
              <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{key.replace('_', ' ')}:</Typography>
            </div>
            <div className={globalClasses.flexCol4}>
              <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{value}</Typography>
            </div>
          </div>
        );
      })}
    </>
  );

  const rows = () => {
    if (!operationType.operations) {
      return <div> No operations</div>;
    }

    return (
      operationType.operations.map((operation) => (
        <div className={globalClasses.flexWrapper}>
          <div className={`${globalClasses.flex} ${globalClasses.flexRow} ${checked.includes(operation.id) && globalClasses.hightlight}`} key={`op_${operation.id}`}>
            <div className={`${globalClasses.flexCol1}`}>
              <Checkbox
                color="primary"
                inputProps={{ 'aria-label': 'operation-checkbox' }}
                edge="start"
                checked={checked.indexOf(operation.id) !== -1}
                onChange={handleToggle(operation.id)}
                tabIndex={-1}
                disableRipple
              />
            </div>
            <div className={`${globalClasses.flexCol1}`}>
              <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{operation.plan_id}</Typography>
            </div>
            <div className={`${globalClasses.flexCol4}`}>
              {displayInOutData(operation)}
            </div>
            {tablet ? (
              <div className={`${globalClasses.flexCol2}`}>
                <Typography variant={tablet ? 'body2' : 'body1'} noWrap>Updated: {operation.updated_at.substring(0, 16).replace('T', ' ')}</Typography>
                <Typography variant={tablet ? 'body2' : 'body1'} noWrap>Researcher: {operation.name}</Typography>
                <Typography variant={tablet ? 'body2' : 'body1'} noWrap>Op Id: {operation.id}</Typography>
              </div>
            ) : (
              <>
                <div className={`${globalClasses.flexCol2}`}>
                  <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{operation.updated_at.substring(0, 16).replace('T', ' ')}</Typography>
                </div>
                <div className={`${globalClasses.flexCol2}`}>
                  <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{operation.name}</Typography>
                </div>
                <div className={`${globalClasses.flexCol1}`}>
                  <Typography variant={tablet ? 'body2' : 'body1'} noWrap>{operation.id}</Typography>
                </div>
              </>
            )}
          </div>
        </div>
      ))
    );
  };

  return (
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
  );
};

ShowByOperation.propTypes = {
  category: string.isRequired,
  // eslint-disable-next-line react/forbid-prop-types
  operationType: object.isRequired,
  setOperationType: func.isRequired,
  setPendingCount: func.isRequired,
  setAlertProps: func.isRequired,
};

export default ShowByOperation;
