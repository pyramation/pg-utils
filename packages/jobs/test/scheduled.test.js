import { getConnections, wrapConn } from './utils';

let db, teardown, app;
const objs = {};
describe('scheduled jobs', () => {
  beforeAll(async () => {
    ({ db, teardown } = await getConnections());
    app = wrapConn(db, 'app_jobs');
  });
  afterAll(async () => {
    await teardown();
  });
  it('connection has admin helpers', async () => {
    const jobs = await app.select('jobs', ['*']);
    expect(jobs.length).toBe(0);
  });
});
