#!/bin/bash -l
#SBATCH -o landsat/landsat-scene.$SLURM_JOBID.$SLURM_TASK_ID
#SBATCH --array=1-360

module load apps/landsatutil

# the task id in the Slurm job array represents the longitude we're looking for
lon=$SLURM_ARRAY_TASK_ID

echo "Looking for the latest image at longitude $lon"

# search this longitude
sceneid=`landsat search --lat 23.5 --lon $lon --cloud 2 --latest 1 | grep "sceneID" | cut -d: -f2 | cut -d, -f1 | sed 's?"??g' | awk '{print $1}'` > /dev/null 2>&1

echo "Found sceneID $sceneid - downloading..."
landsat download --pansharpen $sceneid

# find the downloaded file
file=`find /home/alces/landsat/downloads/$sceneid/ -name "*TIF" | tail -l`

# upload to S3
echo "Uploading latest image to S3 for longitude $lon"

today=`date +%m-%d-%Y`
bucketname="scicolabs-landsat-$today"

# if bucket already exists this command will fail, and we can ignore the failure
alces storage mb $bucketname
alces storage put $file s3://$bucketname/lon$lon-$sceneid.TIF

echo "Uploaded file for longitude $long to s3://$bucketname/lon$lon-$sceneid.TIF."tt
