import utils from './utils';

describe('randObjVal', () => {
  const testObj = {
    French: 'Bonjour',
    Spanish: 'Hola',
    Russian: 'Privet',
    Chinese: 'Nǐ hǎo',
    Italian: 'Ciao',
  };

  it('should return a value from the object', () => {
    const randValue = utils.randObjVal(testObj);

    expect(Object.values(testObj)).toContain(randValue);
  });
});

describe('randString', () => {
  it('should return a string', () => {
    const testString = utils.randString();

    const type = typeof testString;

    expect(type).toBe('string');
  });
});
