# livepeer-source
demo how to create a livepeer source

### configuration

here is sample of environement settings

```bash
export TIMEPLUS_API_KEY=<your timeplus api key>
export LIVEPEER_API_KEY=<your livepeer api key>
export TIMEPLUS_ADDRESS=https://us.timeplus.cloud/workspace-id
```

### run

after install all the dependency, run main.py which will create a versioned kv stream and a livepeer data source.

```
pip install -r requirements.txt
python main.py
```

### how does live peer source works.

the current livepeer source will periodically call live peer api to get all the metrics data, in a hourly timestep for all the dimensions. it will get the 7 days historical data in first call and then incrementally retrieved the updated data. duplicated data will be merged by the version kv.